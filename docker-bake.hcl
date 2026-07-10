variable "source-repository" {
  description = "Git repository URL for the Unreal Engine source code"
  type        = string
  default     = "https://github.com/EpicGames/UnrealEngine.git"
}

variable "source-tag" {
  description = "Git tag or branch to check out from the source repository"
  type        = string
  default     = "5.7.4-release"
}

variable "source-url" {
  description = "Full source reference composed of repository and tag (repository#tag)"
  type        = string
  default = format("%s#%s", source-repository, source-tag)
}

variable "changelist" {
  description = "Specific Unreal Engine changelist to build; set to 'auto' to detect from the source tag"
  type        = string
  default     = "auto"
}

variable "tag-namespace" {
  description = "Docker image tag namespace (organization/name prefix) used for the final images"
  type        = string
  default     = "slonopotamus"
}

variable "image-outputs" {
  description = "List of output configurations for the final images (type, mediatypes, compression, push, unpack)"
  type = list(map(string))
  default = [
    {
      type           = "image"
      oci-mediatypes = true
      compression    = "zstd"
      push           = true
      unpack         = false
    }
  ]
}

variable "linux-baseimage" {
  description = "Base Docker image used for Linux build (docker-image:// or local reference)"
  type        = string
  default     = "docker-image://ubuntu:22.04"
}

variable "windows-baseimage" {
  description = "Base Docker image used for Windows build (docker-image:// or local reference)"
  type        = string
  default     = "docker-image://mcr.microsoft.com/windows/server:ltsc2022"
}

variable "linux-platforms" {
  description = "Target platforms for Linux image builds (e.g., linux/amd64, linux/arm64)"
  type = list(string)
  default = [
    "linux/amd64"
  ]
}

variable "windows-platforms" {
  description = "Target platforms for Windows image builds (e.g., windows/amd64)"
  type = list(string)
  default = [
    "windows/amd64"
  ]
}

variable "common-buildgraph-args" {
  description = "Additional arguments passed to the build graph on all platforms"
  type = list(string)
  default = [
    "-set:HostPlatformOnly=true",
    "-set:WithClient=true",
    "-set:WithDDC=false",
    "-set:WithServer=true",
  ]
}

variable "linux-buildgraph-args" {
  description = "Additional arguments passed to the Linux build graph"
  type = list(string)
  default = [
  ]
}

variable "windows-buildgraph-args" {
  description = "Additional arguments passed to the Windows build graph"
  type = list(string)
  default = [
  ]
}

variable "linux-setup-args" {
  description = "Arguments passed to Setup.sh during Linux engine setup (e.g., '--exclude=Android')"
  type = list(string)
  default = [
    "--exclude=Android",
    "--exclude=Mac",
    "--exclude=Win32",
    "--exclude=Win64",
  ]
}

variable "windows-setup-args" {
  description = "Arguments passed to Setup.bat during Windows engine setup (e.g., '--exclude=Android')"
  type = list(string)
  default = [
    "--exclude=Android",
    "--exclude=Mac",
    "--exclude=Linux",
  ]
}

variable "linux-minimal-tags" {
  description = "Docker tags applied to the final Linux image"
  type = list(string)
  default = [
    format("%s/minimal:%s-linux", tag-namespace, source-tag)
  ]
}

variable "windows-minimal-tags" {
  description = "Docker tags applied to the final Windows image"
  type = list(string)
  default = [
    format("%s/minimal:%s-windows", tag-namespace, source-tag)
  ]
}

target "linux-base" {
  description = "Installs Linux system dependencies required by the Unreal Engine"
  context     = "./linux/base"
  contexts = {
    baseimage = linux-baseimage
  }
  output = [
    {
      type = "cacheonly"
    }
  ]
  platforms = linux-platforms
}

target "linux-source" {
  description = "Clones the Unreal Engine repository and runs Setup.sh to prepare the source tree"
  context     = "./linux/source"
  contexts = {
    base : "target:linux-base"
  }
  args = {
    repository = source-url
    setup_args = join(" ", linux-setup-args)
  }
  secret = [
    {
      id : "GIT_AUTH_TOKEN"
    }
  ]
  output = [
    {
      type = "cacheonly"
    }
  ]
  platforms = linux-platforms
}

target "linux-builder" {
  description = "Runs build graph to build installed engine for Linux"
  context     = "./linux/builder"
  contexts = {
    source : "target:linux-source"
  }
  args = {
    changelist = changelist
    buildgraph_args = join(" ", concat(common-buildgraph-args, linux-buildgraph-args))
  }
  output = [
    {
      type = "cacheonly"
    }
  ]
  platforms = linux-platforms
}

target "linux-minimal" {
  description = "Final Linux image assembled from base and builder layers; tagged and pushed"
  context     = "./linux/minimal"
  contexts = {
    base : "target:linux-base"
    builder : "target:linux-builder"
  }
  tags      = linux-minimal-tags
  output    = image-outputs
  platforms = linux-platforms
}

target "windows-base" {
  description = "Installs Windows system dependencies and prerequisites for the Unreal Engine"
  context     = "windows/base"
  contexts = {
    baseimage = windows-baseimage
  }
  output = [
    {
      type = "cacheonly"
    }
  ]
  platforms = windows-platforms
}

target "windows-source-prep" {
  description = "Clones the Unreal Engine repository into the Windows image"
  context     = "windows/source-prep"
  contexts = {
    base : "target:windows-base"
  }
  args = {
    repository = source-url
  }
  secret = [
    {
      id : "GIT_AUTH_TOKEN"
    }
  ]
  output = [
    {
      type = "cacheonly"
    }
  ]
  platforms = windows-platforms
}

target "windows-vs" {
  description = "Installs the Visual Studio workloads and components required by Unreal Engine"
  context     = "windows/vs"
  contexts = {
    base : "target:windows-base"
    source-prep : "target:windows-source-prep"
  }
  output = [
    {
      type = "cacheonly"
    }
  ]
  platforms = windows-platforms
}

target "windows-source" {
  description = "Runs Setup.bat to prepare the Windows engine source tree"
  context     = "windows/source"
  contexts = {
    source-prep : "target:windows-source-prep"
    vs : "target:windows-vs"
  }
  args = {
    setup_args = join(" ", windows-setup-args)
  }
  output = [
    {
      type = "cacheonly"
    }
  ]
  platforms = windows-platforms
}

target "windows-builder" {
  description = "Runs build graph to produce installed engine for Windows"
  context     = "./windows/builder"
  contexts = {
    source : "target:windows-source"
  }
  args = {
    changelist = changelist
    buildgraph_args = join(" ", concat(common-buildgraph-args, windows-buildgraph-args))
  }
  output = [
    {
      type = "cacheonly"
    }
  ]
  platforms = windows-platforms
}

target "windows-minimal" {
  description = "Final Windows image assembled from builder and VS layers; tagged and pushed"
  context     = "windows/minimal"
  contexts = {
    builder : "target:windows-builder"
    vs : "target:windows-vs"
  }
  tags      = windows-minimal-tags
  output    = image-outputs
  platforms = windows-platforms
}

group "default" {
  targets = ["linux-minimal"]
}
