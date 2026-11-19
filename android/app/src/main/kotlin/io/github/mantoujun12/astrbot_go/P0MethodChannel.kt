package io.github.mantoujun12.astrbot_go

import android.content.Context
import android.content.pm.ApplicationInfo
import android.os.Handler
import android.os.Looper
import android.util.Log
import com.github.luben.zstd.ZstdInputStream
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.apache.commons.compress.archivers.tar.TarArchiveEntry
import org.apache.commons.compress.archivers.tar.TarArchiveInputStream
import java.io.File
import java.io.FileInputStream
import java.io.IOException
import java.nio.file.Files
import java.nio.file.Path
import java.nio.file.Paths
import java.nio.file.attribute.PosixFilePermission
import java.security.MessageDigest
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors
import java.util.concurrent.TimeUnit

/**
 * Debug-only P0 verification channel ("p0/run").
 *
 * Extracts a locally staged base rootfs tarball and runs PRoot commands from
 * docs/P0_VERIFICATION.md. No foreground service, no instance management:
 * the real supervisor lands in P1.
 */
class P0MethodChannel(private val context: Context) : MethodChannel.MethodCallHandler {

    companion object {
        private const val TAG = "P0MethodChannel"
        private const val CHANNEL = "p0/run"
    }

    private val mainHandler = Handler(Looper.getMainLooper())
    private val executor: ExecutorService = Executors.newSingleThreadExecutor()
    private val debuggable =
        (context.applicationInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE) != 0

    /** Base image target; the real per-baseId layout arrives in P1. */
    private val rootfsDir: File
        get() = File(context.filesDir, "runtimes/base/p0/rootfs")

    private val prootTmpDir: File
        get() = File(context.cacheDir, "proot-tmp")

    private val nativeLibraryDir: String
        get() = context.applicationInfo.nativeLibraryDir ?: ""

    fun register(messenger: BinaryMessenger) {
        MethodChannel(messenger, CHANNEL).setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (!debuggable) {
            // The p0/run channel is P0-only and must not exist in release builds.
            result.error("p0/debug-only", "The p0/run channel is disabled in release builds", null)
            return
        }
        when (call.method) {
            "status" -> status(result)
            "extractBaseImage" -> extractBaseImage(call, result)
            "runProot" -> runProot(call, result)
            else -> result.notImplemented()
        }
    }

    private fun status(result: MethodChannel.Result) {
        val jniFiles = File(nativeLibraryDir)
            .listFiles { f -> f.name.startsWith("lib") && f.name.endsWith(".so") }
            ?.map { it.name }
            ?.sorted()
            ?: emptyList()
        result.success(
            mapOf(
                "extractedRootfsDir" to if (rootfsDir.isDirectory) rootfsDir.absolutePath else null,
                "nativeLibraryDir" to nativeLibraryDir,
                "jniLibs" to jniFiles,
            )
        )
    }

    private fun extractBaseImage(call: MethodCall, result: MethodChannel.Result) {
        val tarZstPath = call.argument<String>("tarZstPath")
        val sha256Hex = call.argument<String>("sha256Hex")
        if (tarZstPath.isNullOrBlank()) {
            result.error("p0/bad-args", "tarZstPath is required", null)
            return
        }
        executor.execute {
            val outcome = try {
                extract(tarZstPath, sha256Hex)
            } catch (e: Exception) {
                mapOf("ok" to false, "error" to (e.message ?: e.javaClass.simpleName))
            }
            mainHandler.post { result.success(outcome) }
        }
    }

    private fun extract(tarZstPath: String, sha256Hex: String?): Map<String, Any> {
        val tarFile = File(tarZstPath)
        if (!tarFile.isFile) {
            throw IOException("Not a readable file: $tarZstPath")
        }
        if (!sha256Hex.isNullOrBlank()) {
            val actual = sha256(tarFile)
            if (!actual.equals(sha256Hex.trim(), ignoreCase = true)) {
                throw IOException("SHA-256 mismatch: expected $sha256Hex, got $actual")
            }
        }

        val start = System.currentTimeMillis()
        val baseDir = rootfsDir.parentFile
        baseDir.mkdirs()
        // Extract into a temp dir, then atomically rename into place: a failed
        // extraction must never leave a half-written rootfs behind.
        val tmpDir = Files.createTempDirectory(baseDir.toPath(), "rootfs-tmp-")
        var entries = 0
        var bytes = 0L
        try {
            TarArchiveInputStream(ZstdInputStream(FileInputStream(tarFile))).use { tar ->
                while (true) {
                    val entry = tar.nextTarEntry ?: break
                    extractEntry(tmpDir, entry, tar)
                    entries++
                    if (!entry.isDirectory && !entry.isSymbolicLink && !entry.isLink) {
                        bytes += entry.size
                    }
                }
            }
            if (rootfsDir.exists()) {
                rootfsDir.deleteRecursively()
            }
            Files.move(tmpDir, rootfsDir.toPath())
        } catch (e: Exception) {
            tmpDir.toFile().deleteRecursively()
            throw e
        }
        return mapOf(
            "ok" to true,
            "entries" to entries,
            "bytes" to bytes,
            "durationMs" to (System.currentTimeMillis() - start),
        )
    }

    /** Normalize a tar entry/link name to a path inside [dir], rejecting traversal. */
    private fun resolveInside(dir: Path, name: String): Path {
        var cleaned = name
        while (cleaned.startsWith("./")) cleaned = cleaned.substring(2)
        cleaned = cleaned.trimStart('/')
        val target = dir.resolve(cleaned).normalize()
        if (!target.startsWith(dir)) {
            throw IOException("Refusing tar entry outside the target dir: $name")
        }
        return target
    }

    private fun extractEntry(dir: Path, entry: TarArchiveEntry, tar: TarArchiveInputStream) {
        val target = resolveInside(dir, entry.name)
        if (entry.isDirectory) {
            Files.createDirectories(target)
            return
        }
        Files.createDirectories(target.parent)
        when {
            entry.isSymbolicLink -> Files.createSymbolicLink(target, Paths.get(entry.linkName))

            entry.isLink -> {
                val source = resolveInside(dir, entry.linkName)
                try {
                    Files.createLink(target, source)
                } catch (_: IOException) {
                    // Some tarballs order hardlinks before their target file; copy instead.
                    Files.copy(source, target)
                }
            }

            entry.isFile -> {
                Files.newOutputStream(target).use { out -> tar.copyTo(out) }
                Files.setPosixFilePermissions(target, posixPermissions(entry.mode))
            }

            else -> Log.w(TAG, "Skipping non-regular tar entry (device/fifo): ${entry.name}")
        }
    }

    private fun posixPermissions(mode: Int): Set<PosixFilePermission> {
        val m = mode and 0x1FF
        val perms = mutableSetOf<PosixFilePermission>()
        if (m and 0x100 != 0) perms.add(PosixFilePermission.OWNER_READ)
        if (m and 0x080 != 0) perms.add(PosixFilePermission.OWNER_WRITE)
        if (m and 0x040 != 0) perms.add(PosixFilePermission.OWNER_EXECUTE)
        if (m and 0x020 != 0) perms.add(PosixFilePermission.GROUP_READ)
        if (m and 0x010 != 0) perms.add(PosixFilePermission.GROUP_WRITE)
        if (m and 0x008 != 0) perms.add(PosixFilePermission.GROUP_EXECUTE)
        if (m and 0x004 != 0) perms.add(PosixFilePermission.OTHERS_READ)
        if (m and 0x002 != 0) perms.add(PosixFilePermission.OTHERS_WRITE)
        if (m and 0x001 != 0) perms.add(PosixFilePermission.OTHERS_EXECUTE)
        return perms
    }

    private fun sha256(file: File): String =
        MessageDigest.getInstance("SHA-256").let { digest ->
            FileInputStream(file).use { input ->
                val buf = ByteArray(64 * 1024)
                while (true) {
                    val n = input.read(buf)
                    if (n < 0) break
                    digest.update(buf, 0, n)
                }
            }
            digest.digest().joinToString("") { "%02x".format(it) }
        }

    private fun runProot(call: MethodCall, result: MethodChannel.Result) {
        @Suppress("UNCHECKED_CAST")
        val args = call.argument<List<String>>("args") ?: emptyList()
        val timeoutSec = call.argument<Int>("timeoutSec") ?: 120
        if (!rootfsDir.isDirectory) {
            result.error("p0/no-rootfs", "Base rootfs is not extracted yet", null)
            return
        }
        executor.execute {
            val outcome = try {
                runProotBlocking(args, timeoutSec)
            } catch (e: Exception) {
                mapOf<String, Any?>(
                    "exitCode" to null,
                    "output" to (e.message ?: e.javaClass.simpleName),
                    "durationMs" to 0L,
                    "timedOut" to false,
                )
            }
            mainHandler.post { result.success(outcome) }
        }
    }

    private fun runProotBlocking(args: List<String>, timeoutSec: Int): Map<String, Any?> {
        // shortcut: P0 harness does not track the full child tree; the real
        // supervisor (process-group kill, orphan detection) lands in P1.
        // shortcut: P0 intentionally skips generating /etc/resolv.conf from
        // Android's DNS; the P0 smoke commands need no DNS.
        val argv = mutableListOf(
            "$nativeLibraryDir/libproot.so",
            "--kill-on-exit",
            "--link2symlink",
            "-0",
            "-r", rootfsDir.absolutePath,
            "-b", "/dev",
            "-b", "/proc",
            "-b", "/sys",
            "-w", "/",
            "/usr/bin/env",
            "PATH=/usr/local/bin:/usr/bin:/bin",
            "UV_PYTHON_INSTALL_DIR=/opt/python",
            "PYTHONDONTWRITEBYTECODE=1",
        )
        argv.addAll(args)
        // Never log env values that could carry secrets (none today); argv alone is safe.
        Log.d(TAG, "runProot argv: ${argv.joinToString(" ")}")

        prootTmpDir.mkdirs()
        val builder = ProcessBuilder(argv).redirectErrorStream(true)
        builder.environment().apply {
            put("PROOT_TMP_DIR", prootTmpDir.absolutePath)
            put("PROOT_TEMP", prootTmpDir.absolutePath)
            // Android 15 blocks some seccomp syscalls PRoot relies on; disabling
            // seccomp filtering inside PRoot works around it (see docs/P0_RUNBOOK.md).
            put("PROOT_NO_SECCOMP", "1")
            put("LD_LIBRARY_PATH", nativeLibraryDir)
            val loader = File(nativeLibraryDir, "libproot-loader.so")
            if (loader.isFile) {
                put("PROOT_LOADER", loader.absolutePath)
            }
        }

        val start = System.currentTimeMillis()
        val output = StringBuilder()
        val process = builder.start()
        val reader = Thread {
            process.inputStream.bufferedReader().useLines { lines ->
                lines.forEach { output.appendLine(it) }
            }
        }
        reader.isDaemon = true
        reader.start()

        var timedOut = false
        try {
            if (!process.waitFor(timeoutSec.toLong(), TimeUnit.SECONDS)) {
                timedOut = true
                process.destroyForcibly()
            }
        } finally {
            reader.join(2000)
            // Belt and braces: make sure the guest is gone before reporting.
            process.destroyForcibly()
        }
        return mapOf(
            "exitCode" to if (timedOut) null else process.exitValue(),
            "output" to output.toString(),
            "durationMs" to (System.currentTimeMillis() - start),
            "timedOut" to timedOut,
        )
    }
}
