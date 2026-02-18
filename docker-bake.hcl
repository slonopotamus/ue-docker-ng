variable "repository" {
  type = string
  default = "https://github.com/EpicGames/UnrealEngine.git#5.7.3-release"
}

variable "changelist" {
  type = string
  default = "auto"
}

variable "linux-baseimage" {
  type = string
  default = "docker-image://ubuntu:22.04"
}

variable "linux-platforms" {
  type = list(string)
  default = [
    "linux/amd64"
  ]
}

variable "windows-baseimage" {
  type = string
  default = "docker-image://mcr.microsoft.com/windows/server:ltsc2022"
}

variable "windows-platforms" {
  type = list(string)
  default = [
    "windows/amd64"
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
    base: "target:linux-base"
  }
  args = {
    repository = repository
  }
  secret = [
    {
      id: "GIT_AUTH_TOKEN"
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
    source: "target:linux-source"
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
    "base": "target:linux-base"
    "builder": "target:linux-builder"
  }
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
    base: "target:windows-base"
  }
  args = {
    repository = repository
  }
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
    base: "target:windows-base"
    source-prep: "target:windows-source-prep"
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
    source-prep: "target:windows-source-prep"
    vs: "target:windows-vs"
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
    source: "target:windows-source"
  }
  args = {
    changelist = changelist
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
    builder: "target:windows-builder"
    vs: "target:windows-vs"
  }
  platforms = windows-platforms
}

group "default" {
  targets = ["linux-minimal"]
}
