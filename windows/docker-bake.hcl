variable "baseimage" {
  type = string
  default = "docker-image://mcr.microsoft.com/windows/server:ltsc2025"
}

variable "verbose" {
  type = bool
  default = false
}

variable "repository" {
  type = string
  default = "https://github.com/EpicGames/UnrealEngine.git#5.6.1-release"
}

variable "platforms" {
  type = list(string)
  default = [
    "windows/amd64"
  ]
}

target "base" {
  context = "windows/base"
  contexts = {
    baseimage = "docker-image://mcr.microsoft.com/windows/servercore:${basetag}"
  }
  platforms = platforms
}

target "source" {
  context = "windows/source"
  contexts = {
    base: "target:base"
  }
  args = {
    verbose = verbose
  }
  platforms = platforms
}

target "vs" {
  context = "windows/vs"
  contexts = {
    base: "target:base"
    source: "target:source"
  }
  platforms = platforms
}

target "source-with-vs" {
  context = "windows/source-with-vs"
  contexts = {
    source: "target:source"
    vs: "target:vs"
  }
  platforms = platforms
}

target "minimal" {
  context = "windows/minimal"
  contexts = {
    source-with-vs: "target:source-with-vs"
    vs: "target:vs"
  }
  platforms = platforms
}

group "default" {
  targets = ["minimal"]
}
