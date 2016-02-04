function retrieve_constant ()

; This function is used to retrieve constants used for ILAMB Package.
;
; input variables and corresponding Values:
;
;

begin

  constants             = 1
  constants@EarthRadius = 6371220.0 ; in meter
  constants@Radian      = 0.01745
  constants@EulerNumb   = 2.7183

  return(constants)

end
