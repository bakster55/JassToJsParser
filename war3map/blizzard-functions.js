function ModuloInteger(dividend,divisor) {
    var modulus = dividend - R2I(dividend / divisor) * divisor
 
     
     
     
    if ((modulus < 0)) {
         modulus = modulus + divisor
    }
 
     return modulus
 }