; Main code for ABM

breed [As A] ; Altrusist (Represents E. coli SM10lambdapri)
breed [Ss S] ; Selfish/cheaters (Represents E. coli MG1655)

; Setup global variables
globals [step loss_no kept_no]

; Setup variables belonging to the turtles
turtles-own [energy arg]
patches-own [food]

to setup
  clear-all
  setup-patches
  setup-turtles
  reset-ticks
  set step 0
end

to setup-patches
  ask patches [
    set pcolor white
    set food starting_food ; Food value that will be reduced overtime
  ]

  if antibiotic_patch = "1" [ask patch 0 0 [set pcolor 135]]

end

to setup-turtles
  create-turtles starting_turtles
  ask turtles [
    setxy random-xcor random-ycor
    set energy starting_energy
    set breed Ss
  ]

  ask turtles [set arg 0]
  ask n-of (%_alt / 100 * starting_turtles) turtles [set breed As]
  ask n-of (%_arg_Alt / 100 * count As) As [set arg 2] ; Default is that the MGE can transfer (have plasmid)
  ask n-of ((%_arg_Total - %_arg_Alt) / 100 * count Ss) Ss [set arg 2]
  kulayan

end

to go
  ; setup-patches ; When there is an antibiotic patch already
  if ticks mod stay = 0 [move-turtles]
  ask turtles [set energy (energy - 0.5)] ; Changed

  if mobility = "mobile" [recombine]
  if antibiotic_patch = "1"  [one-antibiotic]

  cost-mge

  give-food
  ;;mutate
  check-death
  check-mge

  kulayan
  reproduce

  tick

end

; Recombination is designed to be 1:1
; rec_rate (recombination rate)
to recombine

  ask patches[
    ask As-here with [arg = 2] [
      if rec_rate > random-float 1 [
        if count turtles-here with [arg = 0 or arg = 1] > 0 [
          ask one-of other turtles-here with [arg = 0 or arg = 1] [
          set energy (energy - acquisition_cost); Plasmid acquisition cost
          set arg 2 ; Agent will be (a) resistant and (b) have a plasmid that can be transferred
          ;set breed As ;; Keep this because "enforcement mechanism"

        ]
      ]
        set energy (energy - rec_cost) ; Recombination cost for the donor if recombination is successful?
    ]
  ]
  ]

end

to one-antibiotic
  if good_status = "private" [
    ask turtles with [arg = 0] [
      ;let dist_ab (distancexy 0 0)
      ;set energy (energy - (mcon / dist_ab))
      set energy (energy - (mcon) )
    ]
  ]


  if good_status = "public" [
    ask patches [
      if count turtles-here != 0 [
        let public_good (count turtles-here with [arg = 1 or arg = 2] * mpub) / count turtles-here ; public_good for each turtle in the patch

        ask turtles-here with [arg = 0] [
          ;let dist_ab (distancexy 0 0)
          ;set energy (energy - ((mcon / dist_ab)/(1 + public_good)))
         set energy (energy - (mcon / (1 + public_good)))
        ]
      ]
    ]
  ]
end

to cost-mge

  ask turtles with [arg = 2][
    ; Cost due to presence of plasmid in both the recombiner and non-recombiner
    set energy (energy - maintenance_cost)
  ]

  ; No cost for the presence of the MGE only (arg = 1)

end

; If the energy of the agent with the arg = 1 is below a threshold value, the plasmid (ability of the MGE to be transferred) will be lost.
to check-mge
  let loss_i count As with [arg = 2]
  ask turtles with [arg = 2]
  [
    let tval random-float 1
    if energy < 1 and tval < transposition_rate [ set arg 1 ]
    if energy < 1 and tval > transposition_rate [ set arg 0 ]
    ;if tval < (transposition_rate / energy) [set arg 1 ]
    ;if tval > (transposition_rate / energy) [ set arg 0 ]
  ]


  let loss_f count As with [arg = 2]

  ; Number of lost plasmids, number of kept plasmi
  set loss_no (loss_i - loss_f)
  set kept_no (loss_i - loss_no)
end

; Provides additional fitness value (additional energy) if the bacterium landed on a patch with food
to give-food
  ask patches [
    ask turtles-here [
      if food > 0 [
        set energy energy + 1
        set food food - f_con
      ]

      if food <= 0 [set pcolor 0]
    ]

  ]

end


to mutate
  ask As [if mut_rate > random-float 1 [set breed Ss]]
  ask Ss [if mut_rate > random-float 1 [set breed As]]
end

to check-death
  ask turtles [
    if energy <= 0 [die]
  ]
end

to reproduce
  ;let avefit (mean [energy] of turtles)
  ask As [
    if energy >= starting_energy [
      hatch 1 [set energy starting_energy]
      set energy (energy - starting_energy)
    ]

    if mut_rate > random-float 1 [set breed Ss]
  ]

  ask Ss [
    if energy >= starting_energy [
      hatch 1 [set energy starting_energy]
      set energy (energy - starting_energy)
    ]

    if mut_rate > random-float 1 [set breed As]

  ]


end

to move-turtles
  ask turtles [

    right random 360

    ; Check for boundary in the x-direction
    if patch-at dx 0 = nobody [
      set heading (- heading)
    ]

    ; Check for boundary in the y-direction
    if patch-at 0 dy = nobody [
      set heading (180 - heading)
    ]

     forward 1
  ]



end

; Have to be edited
to kulayan

  ask As with [arg = 2][set color 95] ;; Blue
  ask As with [arg = 1][set color 95] ;; Blue
  ask As with [arg = 0][set color 97] ;; Light blue
  ask Ss with [arg = 2][set color 25] ;; Orange
  ask Ss with [arg = 1][set color 25] ;; Orange
  ask Ss with [arg = 0][set color 27] ;; Light orange
end
