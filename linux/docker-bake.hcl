variable "baseimage" {
  type = string
  default = "docker-image://ubuntu:22.04"
}

variable "verbose" {
  type = bool
  default = false
}

variable "repository" {
  type = string
  default = "https://github.com/EpicGames/UnrealEngine.git#5.7.3-release"
}

variable "platforms" {
  type = list(string)
  default = [
    "linux/amd64"
  ]
}

target "base" {
  context = "linux/base"
  contexts = {
    baseimage = baseimage
  }
  platforms = platforms
}

target "source" {
  context = "linux/source"
  contexts = {
    base: "target:base"
  }
  args = {
    repository = repository
    verbose = verbose
  }
  secret = [
    {
      id: "GIT_AUTH_TOKEN"
    }
  ]
  platforms = platforms
}

target "builder" {
  context = "linux/builder"
  contexts = {
    source: "target:source"
  }
  platforms = platforms
}

target "minimal" {
  context = "linux/minimal"
  contexts = {
    "base": "target:base"
    "builder": "target:builder"
  }
  platforms = platforms
}

group "default" {
  targets = ["minimal"]
}
