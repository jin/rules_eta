def _eta_binary_impl(ctx):

    # TODO: Trim unnecessary inputs
    eta_inputs = [
        ctx.file._eta,
        ctx.file._eta_dev,
        # ctx.file._eta_pkg,
        # ctx.file._eta_serv_jar
    ] # + ctx.files._dot_etlas_deps + ctx.files._dot_eta_deps

    args = ctx.actions.args()

    # If using etlas
    # args.add_all(["exec", "eta", "--", "Main.hs"])

    # If using eta
    args.add_all(["-metricsdir", "metrics"])
    args.add_all([f.short_path for f in ctx.files.srcs])

    # TODO: Identify outputs
    _jar = ctx.actions.declare_file("Main.jar")
    # exe = ctx.actions.declare_file("RunMain.jar")
    # mainhi = ctx.actions.declare_file("Main.hi")

    metrics_dir = ctx.actions.declare_directory("metrics")

    # Regular compile action
    ctx.actions.run(
        inputs = ctx.files.srcs + eta_inputs,
        outputs = [_jar, metrics_dir],
        # outputs = [_jar, exe, mainhi],
        executable = ctx.executable._eta_dev,
        # executable = ctx.executable._etlas,
        arguments = [args],
        mnemonic = "EtaCompile",
        use_default_shell_env = True, # Try not to use default shell env for hermeticity
        progress_message = "Compiling %s using Eta" % ctx.attr.name,
    )

    # Using sh -c /bin/bash
    # ctx.actions.run_shell(
    #     inputs = ctx.files.srcs + eta_inputs,
    #     outputs = [mainjar],
    #     arguments = [args],
    #     command = "eta",
    #     mnemonic = "EtaCompile",
    #     use_default_shell_env = True,
    # )


    return struct(
        # executable = exe, # TODO Support `bazel run`
        files = depset([_jar]),
    )

ETA_BINARY_PACKAGE_PREFIX = "binaries/cdnverify.eta-lang.org/eta-0.8.6.1/binaries/x86_64-osx"

eta_binary = rule(
    implementation = _eta_binary_impl,
    attrs = {
        "srcs": attr.label_list(
            allow_files = [".hs"]
        ),
        # "deps": attr.label_list(),
        "_etlas": attr.label(
            default = "//eta:etlas",
            allow_single_file = True,
            executable = True,
            cfg = "host",
        ),
        "_eta": attr.label(
            default = "@etlas//:%s/eta" % ETA_BINARY_PACKAGE_PREFIX,
            allow_single_file = True,
            executable = True,
            cfg = "host",
        ),
        "_eta_dev": attr.label(
            default = "@eta_dev//:eta",
            allow_single_file = True,
            executable = True,
            cfg = "host",
        ),
        # "_eta_pkg": attr.label(
        #     default = "@etlas//:%s/eta-pkg" % ETA_BINARY_PACKAGE_PREFIX,
        #     allow_single_file = True,
        #     executable = True,
        #     cfg = "host",
        # ),
        # "_eta_serv_jar": attr.label(
        #     default = "@etlas//:%s/eta-serv.jar" % ETA_BINARY_PACKAGE_PREFIX,
        #     allow_single_file = True,
        #     executable = True,
        #     cfg = "host",
        # ),
        "_dot_etlas_deps": attr.label(
            default = "@etlas//:everything",
            allow_files = True,
        ),
        "_dot_eta_deps": attr.label(
            default = "@eta//:everything",
            allow_files = True,
        )
    },
    # executable = True,
)

def eta_repositories():
    native.new_local_repository(
        name = "etlas",
        path = "/Users/jingwen/.etlas/",
        build_file = "//eta:etlas.BUILD"
    )

    native.new_local_repository(
        name = "eta",
        path = "/Users/jingwen/.eta/",
        build_file = "//eta:eta.BUILD"
    )

    native.new_local_repository(
        name = "eta_dev",
        path = "/Users/jingwen/.local/bin",
        build_file_content = """
package(default_visibility = ["//visibility:public"])

filegroup(
    name = "bin",
    srcs = glob(["*"]),
)
"""
    )
