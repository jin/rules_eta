workspace(name = "build_bazel_rules_eta")

load("//eta:defs.bzl", "eta_repositories")

eta_repositories()

RULES_HASKELL_VERSION = "0.6"

http_archive(
    name = "io_tweag_rules_haskell",
    strip_prefix = "rules_haskell-%s" % RULES_HASKELL_VERSION,
    urls = ["https://github.com/tweag/rules_haskell/archive/v%s.tar.gz" % RULES_HASKELL_VERSION],
)

load("@io_tweag_rules_haskell//haskell:repositories.bzl", "haskell_repositories")
haskell_repositories()

register_toolchains("//:ghc")

new_local_repository(
    name = "my_ghc",
    path = "/usr/local", # Change path accordingly.
    build_file_content = """
package(default_visibility = ["//visibility:public"])
filegroup(
    name = "bin",
    srcs = glob(["bin/ghc*"]) + ["bin/hsc2hs", "bin/haddock"],
)
"""
)
