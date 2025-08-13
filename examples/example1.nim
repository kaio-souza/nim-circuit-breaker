import ../src/circuit_breaker, times,os

proc onOpened() =
  echo "[LOG] Circuito ABERTO"

proc onClosed() =
  echo "[LOG] Circuito FECHADO"


proc onHalfOpen() =
  echo "[LOG] Circuito MEIO ABERTO"


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
        raise newException(IOError, "Erro simulado")
      else:
        "Tudo certo"
  )
  sleep(2000)
  echo result

