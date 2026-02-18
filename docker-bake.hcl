variable "source-repository" {
  type    = string
  default = "https://github.com/EpicGames/UnrealEngine.git"
}

variable "source-tag" {
  type    = string
  default = "5.7.3-release"
}

variable "source-url" {
  type = string
  default = format("%s#%s", source-repository, source-tag)
}

variable "changelist" {
  type    = string
  default = "auto"
}

variable "tag-namespace" {
  type    = string
  default = "slonopotamus"
}

variable "image-outputs" {
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
  type    = string
  default = "docker-image://ubuntu:22.04"
}

variable "windows-baseimage" {
  type    = string
  default = "docker-image://mcr.microsoft.com/windows/server:ltsc2022"
}

variable "linux-platforms" {
  type = list(string)
  default = [
    "linux/amd64"
  ]
}

variable "windows-platforms" {
  type = list(string)
  default = [
    "windows/amd64"
  ]
}

variable "linux-buildgraph-args" {
  type = list(string)
  default = [
  ]
}

variable "windows-buildgraph-args" {
  type = list(string)
  default = [
  ]
}

variable "linux-setup-args" {
  type = list(string)
  default = [
    "--exclude=Android",
    "--exclude=Mac",
    "--exclude=Win32",
    "--exclude=Win64",
  ]
}

variable "windows-setup-args" {
  type = list(string)
  default = [
    "--exclude=Android",
    "--exclude=Mac",
    "--exclude=Linux",
  ]
}

variable "linux-minimal-tags" {
  type = [string]
  default = [
    format("%s/minimal:%s-linux", tag-namespace, source-tag)
  ]
}

variable "windows-minimal-tags" {
  type = [string]
  default = [
    format("%s/minimal:%s-windows", tag-namespace, source-tag)
  ]
}

target "linux-base" {
  context = "./linux/base"
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
  context = "./linux/source"
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
  context = "./linux/builder"
  contexts = {
    common : "./common"
    source : "target:linux-source"
  }
  args = {
    changelist = changelist
    buildgraph_args = join(" ", linux-buildgraph-args)
  }
  output = [
    {
      type = "cacheonly"
    }
  ]
  platforms = linux-platforms
}

target "linux-minimal" {
  context = "./linux/minimal"
  contexts = {
    base : "target:linux-base"
    builder : "target:linux-builder"
  }
  tags      = linux-minimal-tags
  output    = image-outputs
  platforms = linux-platforms
}

target "windows-base" {
  context = "windows/base"
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
  context = "windows/source-prep"
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
  context = "windows/vs"
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
  context = "windows/source"
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
  context = "./windows/builder"
  contexts = {
    common : "./common"
    source : "target:windows-source"
  }
  args = {
    changelist = changelist
    buildgraph_args = join(" ", windows-buildgraph-args)
  }
  output = [
    {
      type = "cacheonly"
    }
  ]
  platforms = windows-platforms
}

target "windows-minimal" {
  context = "windows/minimal"
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
