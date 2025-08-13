# Circuit Breaker

A lightweight and performative library to implement the Circuit Breaker framework in Nim applications. Inspired by the best resiliency practices of distributed systems, this library allows you to control errors in external calls (such as APIs, databases or network services), avoiding error cascades and overload.

### 🔐 Use Cases
- Integration with unstable APIs
- Communication with microservices
- Payment systems or external partners



### ✨ Resources
- Open, closed and half-open mode
- Support the spread of faults and time delays configured
- Automatic reset after configurable interval
- Easy integration with synchronous functions



### 🔧 Example:
```nim
import ../src/circuit_breaker, times,os

proc onOpened() =
  echo "[LOG] OPENED"

proc onClosed() =
  echo "[LOG] CLOSED"


proc onHalfOpen() =
  echo "[LOG] HALF-OPEN"


var cb = newCircuitBreaker(
  failureThreshold = 1,
  recoveryTimeout = initDuration(seconds = 1) ,
  onOpen = onOpened,
  onClose = onClosed,
  onHalfOpen = onHalfOpen
)

for i in 0..10:
  let result = cb.call(
    fn = proc(): string =
      if i mod 3 == 0:
        raise newException(IOError, "SimulatedError")
      else:
        "OK"
  )
  sleep(2000)
  echo result

```
### 🚦 States

- **Closed**: chats are normally allowed. If the limit of failures is reached, it is silent for Aberto.
- **Open**: all calls are blocked instantly.
- **Half-Open**: allows a test call after or recoveryTimeout.




