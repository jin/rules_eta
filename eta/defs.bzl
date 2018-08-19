def _eta_library_impl(ctx):
    eta_inputs = [ctx.file._eta]

    args = ctx.actions.args()
    args.add_all(["-metricsdir", "metrics"])
    args.add_all(["-o", ctx.outputs._jar.path])
    args.add_all([f.short_path for f in ctx.files.srcs])

    metrics_dir = ctx.actions.declare_directory("metrics")

    # Regular compile action
    ctx.actions.run(
        arguments = [args],
        executable = ctx.executable._eta,
        inputs = ctx.files.srcs + eta_inputs,
        mnemonic = "EtaCompile",
        outputs = [ctx.outputs._jar, metrics_dir],
        progress_message = "Compiling %s using Eta" % ctx.attr.name,
        use_default_shell_env = True, # TODO: Needed to pass `--action_env=HOME`. Try not to use default shell env for hermeticity
    )

    return [
        DefaultInfo(
            files = depset([ctx.outputs._jar]),
        ),
        JavaInfo(
            output_jar = ctx.outputs._jar,
            compile_jar = ctx.outputs._jar, # TODO: ijar?
        )
    ]

# Unused until the https://github.com/typelead/eta/commit/f37e972b6a6d2ad6140718afbf0a4eb2612f51d0
# is in a release.
# ETA_BINARY_PACKAGE_PREFIX = "binaries/cdnverify.eta-lang.org/eta-0.8.6.1/binaries/x86_64-osx"

eta_library = rule(
    implementation = _eta_library_impl,
    outputs = {
        "_jar": "%{name}.jar",
    },
    attrs = {
        "srcs": attr.label_list(allow_files = [".hs"]),
        # TODO: Figure out provider situation
        # "deps": attr.label_list(),
        # TODO: Download eta compiler directly
        "_eta": attr.label(
            default = "@eta//:eta",
            allow_single_file = True,
            executable = True,
            cfg = "host",
        ),
    },
)

def eta_repositories(bin_path):
    native.new_local_repository(
        name = "eta",
        path = bin_path,
        build_file_content = """
package(default_visibility = ["//visibility:public"])

filegroup(
    name = "bin",
    srcs = glob(["*"]),
)
"""
    )
