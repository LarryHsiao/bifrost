import jetbrains.buildServer.configs.kotlin.*
import jetbrains.buildServer.configs.kotlin.buildSteps.script
import jetbrains.buildServer.configs.kotlin.triggers.vcs
import jetbrains.buildServer.configs.kotlin.vcs.GitVcsRoot

/*
Version-controlled TeamCity config for bifrost, the UI package Metis and
Snotra share — mirrors snotra_app/.teamcity/settings.kts.

One build config:
  - UnitTest: `flutter analyze` + `flutter test` on every new commit,
    on any branch. That is all bifrost's CI does: it ships nothing on
    its own (the apps fetch it through git), so there is no release
    config.

The Flutter SDK comes from fvm, pinned in .fvmrc to the OLDER of the two
apps' pins (Snotra 3.35.7; Metis 3.41.0), so a change that passes here
also builds in both apps. Raise it only together with Snotra's.

No requirements{} pin: the package needs no Android SDK, Xcode or
system SQLite, so any agent with fvm will do.

The VCS root authenticates with an uploaded SSH key named
"bifrost-deploy-key" in this TeamCity project (its public half is a
read-only deploy key on GitHub's LarryHsiao/bifrost), the way
snotra_app's root started. If the root is later switched in the UI
(snotra_app's moved to HTTPS + a stored token), TeamCity writes a patch
under .teamcity/patches; fold it in here and delete it.
*/

version = "2024.03"

project {
    vcsRoot(BifrostVcsRoot)
    buildType(UnitTest)
}

object BifrostVcsRoot : GitVcsRoot({
    id("BifrostVcsRoot")
    name = "bifrost"
    url = "git@github.com:LarryHsiao/bifrost.git"
    branch = "refs/heads/main"
    branchSpec = "+:refs/heads/*"
    authMethod = uploadedKey {
        uploadedKey = "bifrost-deploy-key"
    }
})

object UnitTest : BuildType({
    id("BifrostUnitTest")
    name = "Unit Test"

    vcs {
        root(BifrostVcsRoot)
    }

    steps {
        script {
            name = "flutter analyze, test"
            scriptContent = """
                #!/usr/bin/env bash
                set -euo pipefail
                fvm flutter pub get
                fvm flutter analyze
                fvm flutter test
            """.trimIndent()
        }
    }

    triggers {
        vcs {
            branchFilter = "+:*"
        }
    }
})
