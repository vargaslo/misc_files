## 
## Contributed by chris forman <cjf41@cam.ac.uk>
##
## Modified by Ernesto Vargas to be consistent with mathworld.wolfram formulas



# parametric equations from http://mathworld.wolfram.com/Ellipsoid.html
proc f {a u v} {
  expr {$a*cos($u) * sin($v)}
}

proc g {b u v} {
  expr {$b*sin($u) * sin($v)}
}

proc h {c u v} {
  expr {$c*cos($v)}
}

# a = semi-axis in x direction
# b = semi-axis in y direction
# c = semi-axis in z direction
# phi = first rotation about z axis in xy plane  [see http://mathworld.wolfram.com/EulerAngles.html]
# theta = second rotation about x axis in zy plane.
# psi = third rotation about z' axis in x'y' plane.
# x = translation in x direction.
# y = translation in y direction
# z = translation in z direction
# eColour is the colour of the ellipse in VMD colour table.

proc draw_ellipsoid { a b c phi theta psi x y z eColour} {
  set PI 3.14159265
  set phi [expr $phi*$PI/180]
  set theta [expr $theta*$PI/180]
  set psi [expr $psi*$PI/180]

  set minu 0
  set maxu [expr $PI * 2]
  set minv [expr 0]
  set maxv [expr $PI]

  set Nu 40
  set Nv 40
  set du [expr {($maxu - $minu) / ($Nu - 1) }]
  set dv [expr {($maxv - $minv) / ($Nv - 1) }]

  for {set i 0} {$i<$Nu } {incr i} {
    lappend all_u [expr {$minu + $i*$du }]
    lappend all_i $i
  }

  for {set i 0} {$i<$Nv } {incr i} {
    lappend all_v [expr {$minv + $i*$dv }]
    lappend all_j $i
  }

  # compute rotation matrix to get desired orientation
  set a11 [expr {cos($psi)*cos($phi)-cos($theta)*sin($phi)*sin($psi)}]
  set a12 [expr {cos($psi)*sin($phi)+cos($theta)*cos($phi)*sin($psi)}]
  set a13 [expr {sin($psi)*sin($theta)}]
  set a21 [expr {-1*sin($psi)*cos($phi)-cos($theta)*sin($phi)*cos($psi)}]
  set a22 [expr {-1*sin($psi)*sin($phi)+cos($theta)*cos($phi)*cos($psi)}]
  set a23 [expr {cos($psi)*sin($theta)}]
  set a31 [expr {sin($theta)*sin($phi)}]
  set a32 [expr {-1*sin($theta)*cos($phi)}]
  set a33 [expr {cos($theta)}]

  # make another pass through to plot it   
  set cnum [colorinfo num]
  set cmax [colorinfo max]

  foreach u $all_u i $all_i {
    foreach v $all_v j $all_j {
      set fdata($i,$j) [f $a $u $v]
      set gdata($i,$j) [g $b $u $v]
      set hdata($i,$j) [h $c $u $v]

      set fdata_r($i,$j) [expr {($fdata($i,$j)*$a11+$gdata($i,$j)*$a12+$hdata($i,$j)*$a13) + $x}]
      set gdata_r($i,$j) [expr {($fdata($i,$j)*$a21+$gdata($i,$j)*$a22+$hdata($i,$j)*$a23) + $y}]
      set hdata_r($i,$j) [expr {($fdata($i,$j)*$a31+$gdata($i,$j)*$a32+$hdata($i,$j)*$a33) + $z}]
    }
  }

  foreach u $all_u i $all_i {
    foreach v $all_v j $all_j {
      # get the next two corners       
      set i2 [expr {($i + 1) % $Nu}]
      set j2 [expr {($j + 1) % $Nv}]

      draw color $eColour
      draw triangle "$fdata_r($i,$j)   $gdata_r($i,$j)   $hdata_r($i,$j)" \
                    "$fdata_r($i2,$j)  $gdata_r($i2,$j)  $hdata_r($i2,$j)" \
                    "$fdata_r($i2,$j2) $gdata_r($i2,$j2) $hdata_r($i2,$j2)"
      draw triangle "$fdata_r($i2,$j2) $gdata_r($i2,$j2) $hdata_r($i2,$j2)" \
                    "$fdata_r($i,$j2)  $gdata_r($i,$j2)  $hdata_r($i,$j2)" \
                    "$fdata_r($i,$j)   $gdata_r($i,$j)   $hdata_r($i,$j)"
    }
  }
}


draw_ellipsoid 3.21 2.4000000000000004 2.325 18.2351741175661 -76.27875894924485 -23.91775417174994 4.2749999999999995 2.205 7.0920000000000005 yellow
draw_ellipsoid 3.4499999999999997 2.43 2.13 -14.650656368873454 -98.46252421599769 -120.69211669944478 2.0700000000000003 2.88 16.164 yellow
draw_ellipsoid 3.375 2.445 2.145 -13.992771078670245 -98.24108752266146 -120.80979186642364 12.915 12.165000000000001 1.8359999999999999 yellow
draw_ellipsoid 3.135 2.415 2.325 17.829495731245455 -75.50662673964537 -23.060663186035292 10.68 12.78 10.926 yellow
draw_ellipsoid 3.195 2.4000000000000004 2.325 18.78689744491161 -100.65162941220912 23.022084107062344 3.21 9.69 10.908 yellow
draw_ellipsoid 3.4050000000000002 2.43 2.1149999999999998 15.43048687471816 -96.56139600342128 -61.13161495834052 5.43 10.364999999999998 1.8359999999999999 yellow
draw_ellipsoid 3.33 2.445 2.13 14.982519365190889 -96.36619762896615 -60.91781933523953 9.585 4.68 16.146 yellow
draw_ellipsoid 3.12 2.415 2.325 18.280212621942418 -103.0514119670315 22.647925143061588 11.82 5.279999999999999 7.074 yellow

