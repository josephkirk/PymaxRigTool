MacroScript ResetCTR
ButtonText:"ResetCTR"
category:"Rigging"
(
    for i in selection do
		(
            i.position.controller = Position_XYZ()
            i.rotation.controller = Euler_XYZ()
		)
)