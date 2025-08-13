# Package

version       = "0.1.0"
author        = "Kaio Souza"
description   = "A lightweight and high-performance library for implementing the Circuit Breaker pattern in Nim applications. Inspired by distributed system resilience best practices, this library allows you to handle failures in external calls (such as APIs, databases, or network services), avoiding cascading errors and overloads."
license       = "MIT"
srcDir        = "src"


# Dependencies

requires "nim >= 2.2.4"
tags = @["resilience", "circuit breaker", "network", "fault tolerance"]
