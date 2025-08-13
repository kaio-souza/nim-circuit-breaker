import times, options

type
  CircuitState* = enum
    Closed, Open, HalfOpen

  CircuitBreaker* = object
    state: CircuitState
    failureCount: int
    failureThreshold: int
    recoveryTimeout: Duration
    lastFailureTime: DateTime
    onOpen*: proc() {.gcsafe.} = nil
    onClose*: proc() {.gcsafe.} = nil
    onHalfOpen*: proc() {.gcsafe.} = nil

proc newCircuitBreaker*(
  failureThreshold: int,
  recoveryTimeout: Duration,
  onOpen: proc() {.gcsafe.} = nil,
  onClose: proc() {.gcsafe.} = nil,
  onHalfOpen: proc() {.gcsafe.} = nil

): CircuitBreaker =
  CircuitBreaker(
    state: Closed,
    failureCount: 0,
    failureThreshold: failureThreshold,
    recoveryTimeout: recoveryTimeout,
    lastFailureTime: now(),
    onOpen: onOpen,
    onClose: onClose,
    onHalfOpen: onHalfOpen

  )

proc transitionTo*(circuitBreaker: var CircuitBreaker, newState: CircuitState) =
  if circuitBreaker.state != newState:
    case newState 
    of Open:
      if circuitBreaker.onOpen != nil: circuitBreaker.onOpen()
    of Closed:
      if circuitBreaker.onClose != nil: circuitBreaker.onClose()
    of HalfOpen:
      if circuitBreaker.onHalfOpen != nil: circuitBreaker.onHalfOpen()
  circuitBreaker.state = newState

proc call*[T](circuitBreaker: var CircuitBreaker, fn: proc(): T): Option[T] =
  let nowTime = now()

  case circuitBreaker.state:
    of Open:
      if nowTime - circuitBreaker.lastFailureTime > circuitBreaker.recoveryTimeout:
        circuitBreaker.transitionTo(HalfOpen)
      else:
        return none(T)

    of HalfOpen:
      try:
        circuitBreaker.transitionTo(Closed)
        circuitBreaker.failureCount = 0
        return some(fn())
      except CatchableError:
        circuitBreaker.transitionTo(Open)
        circuitBreaker.lastFailureTime = nowTime
        return none(T)

    of Closed:
      try:
        circuitBreaker.failureCount = 0
        return some(fn())
      except CatchableError:
        circuitBreaker.failureCount += 1
        if circuitBreaker.failureCount >= circuitBreaker.failureThreshold:
          circuitBreaker.transitionTo(Open)
          circuitBreaker.lastFailureTime = nowTime
        return none(T)