fn getObname ob =
(
	obstrlist = filterstring ob.name "_"
	if obstrlist.count != 1 then
	(
	obstrlast = obstrlist[obstrlist.count]
	if (classof (obstrlast as integer)) != undefined then
	(
		obname = obstrlist[obstrlist.count-1]
	) else obname = ostrlast
	) else obname = ob.name
	obname
)
fn PointAttachtoMesh ob =
(
	obmesh = ob.mesh
	vertsel = getVertSelection obmesh
	facecorner = #([0,0],[1,0],[0,1],[1,1])
	outloop = false
	oblist = #()
	for v in vertsel do 
	(
		--CreatePointHelper with attachment Constraint
		attachob = Point size:10 box:true wirecolor:yellow
		append oblist attachob
		attachob.position.controller = Attachment()
		obpctr = attachob.position.controller
		obpctr.node =ob
		addNewKey obpctr 0f
		attachkey = AttachCtrl.getKey obpctr 1
		
		in coordsys ob vertpos = getVert obmesh v
		vertface=(meshop.getPolysUsingVert obmesh v)as array
		outloop = true
		for f in vertface while outloop do
		(
			attachkey.face = f
			
			for c in facecorner while outloop do
			(
				attachkey.coord = c
				AttachCtrl.update obpctr
				in coordsys ob testpos = attachob.pos
				--testcon=(dot (normalize vertpos) (normalize testpos)) as integer
				testcon = floor(distance vertpos testpos)
				format "at Face:% corner:% Point pos:% compare to VertPos:% equal %\n" f c testpos vertpos testcon
				if testcon ==0 do
				(
					attachkey.coord = c
					AttachCtrl.update obpctr
					outloop=false
					print outloop
				)
			)
		)
	)
	oblist
)
fn sLibResetXForm obj = 
	(
	local ntm = obj.transform
	obj.transform=transMatrix obj.pos
	local piv=obj.objecttransform * inverse obj.transform
	obj.objectoffsetPos  = [0,0,0]
	obj.objectoffsetRot = (quat 0 0 0 1)
	obj.objectoffsetScale = [1,1,1]
	ntm.translation=[0,0,0]
	ntm = piv * ntm
	local xformMod=xform()
	addmodifier obj xformMod
	xformMod.gizmo.transform=ntm
	xformMod.name = "Reset Xform"
	return obj
	)
fn xFormResetter xFRCollapse xFRCopyOrRef = 
	(
	undo "xFormResetter" on
		(
		if selection.count != 0 then
			(
			allObjects = #()
			rigarray = #()
			error = false

			-- Check if groups
			for obj in selection do
				(
				if isgroupmember obj == false and isgrouphead obj == false then
					(
					append allObjects obj
					)
				else error = true
				)
			if error == true then MessageBox "At least one object in your selection is a group and cannot be affected by this script. Please ungroup the objects." title:"xFormResetter"
			else
				(		
				--record hierarchy
				for obj in allObjects do
					(
					par = obj.parent
					kids = obj.children
					append rigarray #(obj, par, kids)
					)

				--dispose of hierarchy
				for obj in allObjects do
					(
					kids = obj.children
					obj.parent = undefined
					for i in kids do
						(
						i.parent = undefined
						)			
					)		

				if xFRCopyOrRef == 2 then
					(
					-- Convert To Reference
					a = #()
					for obj in allObjects do
						(
						if (sLibGetInstancesOfObject obj).count != 0 then append a obj
						)
					while a.count !=0 do
						(
						b = (sLibGetInstancesOfObject a[1]) + a[1]
						sLibConvertsInstancesToReferences b
						a = sLibRemoveItemsFromArray a b				
						)
					)
				else
					(
					-- Uninstance
					for obj in allObjects do 
						(
						if (InstanceMgr.CanMakeObjectsUnique obj) == true then InstanceMgr.MakeObjectsUnique obj #individual
						)
					)

				-- Reset Xform
				for obj in allObjects do 
					(
					flipme = false
					
					-- Reset				
					--if obj.scale.x < 0 or obj.scale.y < 0 or obj.scale.z < 0 then flipme = true
					sLibResetXForm obj
					if flipme == true then 
						(
						local normalMod = Normalmodifier()
						addmodifier obj normalMod
						normalMod.name = ("xFR_NormalFlip")
						normalMod.flip = on
						)
					if xFRCollapse == true then 
						(
						if ((canConvertTo obj SplineShape) == true) and (obj.baseobject.DisplayRenderMesh != true) then 
							(
							convertTo obj SplineShape
							)
						else if (canConvertTo obj Editable_Poly) == true then
							(
							convertTo obj PolyMeshObject
							) else  maxOps.CollapseNode obj on
						)
					)

				-- Pur Hierarchy Back
				for i in rigarray do
					(
					i[1].parent = i[2]
					for w in i[3] do
						(
						w.parent = i[1]
						)	
					)
				)
			)
		)
	)

--create Control
 fn createControlText na te=
 (
	 Ctr = text name:na text:te pos:[0,0,-50] size:20 rotation:(eulerangles -90 0 0)
 )
 fn CreateHalftCircleHelper rad c dis = 
(
	div = 1.8123
	sp = splineShape()
	for i =1 to c do
	(
	dismul=(i-1)*dis
	addnewSpline sp
	addKnot sp i #beziercorner #curve  [0,rad,dismul] [0,rad,dismul] [rad/div,rad,dismul]
	addKnot sp i #bezier #curve [rad,0,dismul] [rad,rad/div,dismul] [rad,-rad/div,dismul]
	addKnot sp i #beziercorner #curve  [0,-rad,dismul] [rad/div,-rad,dismul] [0,-rad,dismul] 
	close sp i
	weldSpline sp 21.0
	)
	updateShape sp
	move sp [0,0,(-(dis*(c-1))/2.0)]
	sp.pivot =[0,0,0]
	collapseStack sp
	sp
)
fn CreateCircleHelper rad c dis = 
(
	div = 1.8123
	sp = splineShape()
	for i =1 to c do
	(
		dismul=(i-1)*dis
	addnewSpline sp
	addKnot sp i #bezier #curve  [0,rad,dismul] [-rad/div,rad,dismul] [rad/div,rad,dismul]
	addKnot sp i #bezier #curve [rad,0,dismul] [rad,rad/div,dismul] [rad,-rad/div,dismul]
	addKnot sp i #bezier #curve  [0,-rad,dismul] [rad/div,-rad,dismul] [-rad/div,-rad,dismul]
	addKnot sp i #bezier #curve [-rad,0,dismul] [-rad,-rad/div,dismul] [-rad,rad/div,dismul]
	close sp i
	weldSpline sp 21.0
	)
	updateShape sp
	move sp [0,0,(-(dis*(c-1))/2.0)]
	sp.pivot =[0,0,0]
	collapseStack sp
	select sp
	sp
)
fn CreateSphereHelper rad =
(
		div = 1.8123
	sp = splineShape()
	addnewSpline sp
	addKnot sp 1 #bezier #curve  [0,rad,0] [-rad/div,rad,0] [rad/div,rad,0]
	addKnot sp 1 #bezier #curve [rad,0,0] [rad,rad/div,0] [rad,-rad/div,0]
	addKnot sp 1 #bezier #curve  [0,-rad,0] [rad/div,-rad,0] [-rad/div,-rad,0]
	addKnot sp 1 #bezier #curve [-rad,0,0] [-rad,-rad/div,0] [-rad,rad/div,0]
	close sp 1
	weldSpline sp 21.0
	addnewSpline sp
	addKnot sp 2 #bezier #curve  [0,0,rad] [0,-rad/div,rad] [0,rad/div,rad]
	addKnot sp 2 #bezier #curve [0,rad,0] [0,rad,rad/div] [0,rad,-rad/div]
	addKnot sp 2 #bezier #curve  [0,0,-rad] [0,rad/div,-rad] [0,-rad/div,-rad]
	addKnot sp 2 #bezier #curve [0,-rad,0] [0,-rad,-rad/div] [0,-rad,rad/div]
	close sp 2
	weldSpline sp 21.0
	updateShape sp
	addnewSpline sp
	addKnot sp 3 #bezier #curve  [rad,0,0] [rad,0,-rad/div] [rad,0,rad/div]
	addKnot sp 3 #bezier #curve [0,0,rad] [rad/div,0,rad] [-rad/div,0,rad]
	addKnot sp 3 #bezier #curve  [-rad,0,0] [-rad,0,rad/div] [-rad,0,-rad/div]
	addKnot sp 3 #bezier #curve [0,0,-rad] [-rad/div,0,-rad] [rad/div,0,-rad]
	close sp 3
	weldSpline sp 21.0
	updateShape sp
	sp
)
mapped fn CreateSphereRoot ls rad =
(
	exparent = ls.parent
	na= ls.name+"_root"
	boRoot = CreateSphereHelper rad
	boRoot.pos = ls.pos
	MatchRotation boRoot ls
	ls.parent = boRoot
	boRoot.parent = exparent
	boRoot
)
fn createStretchBone a b=
(
	bone1 =Bonesys.createbone a b [0,0,1]
	bone2 = copy bone1
	bone2.boneEnable=true
	bone2.pos = b
	bone2.parent = bone1
	bone1.resetBoneStretch()
	bone2.length = bone2.width
	poRoot = createRoot bone1
	poUpnode = copy poRoot
	poUpnode.name = bone1.name +"_Upnode"
	--print (classof poUpnode)
	in coordsys local move poUpnode [0,20,0]
	poUpnode.wirecolor = color 255 0 255
	cirRoot = CreateSphereHelper 10
	cirRoot.wirecolor = color 8 110 135
	cirRoot.pos = bone2.pos
	addLookAt poRoot cirRoot upnode:poUpnode
	pc = position_constraint()
	bone2.position.controller =pc
	pc.appendTarget cirRoot 100
	poRoot.rotation.controller.lookat_vector_length = 2
	poUpnode.parent= cirRoot
	#(poRoot,cirRoot)
)

fn makeStrechBone loop:false =
(
	poRootlist =#()
	SpRootlist =#()
	for b=1 to selection.count do
	(
			bonEnd = copy $[b]
			bonEnd.boneEnable=true
			bonEnd.parent = $[b]
			bonEnd.length = $[b].width
			in coordsys parent bonEnd.pos =[$[b].length,0,0]
			poRoot= CreateRoot $[b]
			append poRootlist poRoot
			$[b].resetBoneStretch()
			if b!=1 do poRoot.parent=SpRootlist[(b-1)]
			poUpnode = copy poRoot
			in coordsys local move poUpnode [0,20,0]
			SpRoot = CreateSphereHelper 10
			SpRoot.wirecolor = color 8 110 135
			SpRoot.pos = bonEnd.pos
			bonEnd.position.controller = position_constraint()
			bonEnd.position.controller.appendTarget SpRoot 100
			append SpRootlist spRoot
			addLookat poRoot SpRoot upnode:poUpnode
			poUpnode.parent = SpRoot
			poUpnode.wirecolor = color 255 0 255
			poUpnode.name = ($[b].name +"_Upnode")
			poRoot.rotation.controller.lookat_vector_length = 2
	)
	if loop == true do
	(
		loopbone = createStretchBone SpRootlist[SpRootlist.count].pos poRootlist[1].pos 
		loopbone[1].parent = SpRootlist[SpRootlist.count]
		poRootlist[1].parent = loopbone[2]
	)
)
 -- drawFreeSpline macros.run "Java" "FreeSpline"
global old_pos
global new_spline
global second_knot_set
global distant = 20
 
fn get_mouse_pos pen_pos old_pen_pos dis:10 =
(
dis = distant
 if old_pos == undefined then old_pos = old_pen_pos
 if distance pen_pos old_pos > dis then
 (
  if second_knot_set then
   addKnot new_spline 1 #smooth #curve pen_pos
  else
  (
   setKnotPoint new_spline 1 2 pen_pos
   second_knot_set = true
  )
  old_pos = pen_pos
  updateShape new_spline
 )-- end if
)-- end fn
fn draw_new_line old_pen_pos =
(
 pickPoint snap:#3D mouseMoveCallback:#(get_mouse_pos,old_pen_pos)
)
fn drawSpline dis:10=
(
	distant=dis
undo"Free Spline"on
(
 new_spline = splineShape ()
 old_pen_pos = pickPoint snap:#3D
 if old_pen_pos == #RightClick then
 (
  delete new_spline
 )
 else
 (
  select new_spline
  new_spline.pos = old_pen_pos
  addNewSpline new_spline
  addKnot new_spline 1 #smooth #curve old_pen_pos
  addKnot new_spline 1 #smooth #curve old_pen_pos
  second_knot_set = false
  draw_new_line old_pen_pos
  new_spline
 )--end else
)--end undo
)
	 -- reverse array
 fn reverseArray a =
(
	ra=#()
	for i=1 to a.count do
	(
		ri = a.count+1-i
		append ra a[ri]
	)
	for i=1 to a.count do
	(
		a[i] = ra[i]
	)
)

 -- matchRotation
fn matchRotation a b =
(
	a.transform = translate (b.transform.rotation as matrix3) a.transform.pos
	r = a.transform.rotation * (inverse b.transform.rotation)
	a.rotation *= r
)

-- AddLookat constraintss
mapped fn addLookAt ob tar upnode:undefined =
(
	obparent = ob.parent
	obchildren = #()
	for o in ob.children do 
	(
		append obchildren o
		o.parent=undefined
	)
	ob.parent=undefined
	ob.rotation.controller = Euler_XYZ()
	rc = Lookat_constraint ()
	ob.rotation.controller = rc
	rc.target_axis = 0
	rc.relative = true
	
	rc.appendTarget tar 100.0
	if upnode!=undefined do
	(
		rc.pickUpNode = upnode
		rc.upnode_world =false
		rc.upnode_axis = 2
		rc.upnode_ctrl = 0
		rc.STOUP_axis =1
		--rc.viewline_length=2
	)
	ob.parent=obparent
	for obc in obchildren do obc.parent = ob
	
)

 -- add custom attributes target to floatScript
fn addTarget ob ctr =
(
	if classof ctr != undefined do
	(
		ob.addTarget "SFrame" ctr.Custom_Attributes[1]
		ob.addTarget "eframe" ctr.Custom_Attributes[2]
		ob.addTarget "cycle" ctr.Custom_Attributes[3]
		ob.addTarget "volume" ctr.Custom_Attributes[4]
		ob.addTarget "reverse" ctr.Custom_Attributes[5]
		ob.addTarget "interval" ctr.Custom_Attributes[6]
		ob.addTarget "row_interval" ctr.Custom_Attributes[7]
		ob.addTarget "YZtimming" ctr.Custom_Attributes[8]
	)
)

 -- add Rotation list controller to the bone
fn SwayTree ob no tar =
(
	if (isValidNode ob) do
	(
		--baseScript
		baseYScript =  "if reverse then direct_rot = -1
else direct_rot = 1
rad2deg = 3.14159265358979/180.0
sin(F*direct_rot*(360.0/(Eframe-Sframe))*cycle + row_interval*NO - interval*OB)*rad2deg * volume * TC"
baseZScript = "if reverse then direct_rot = -1
else direct_rot = 1
rad2deg = 3.14159265358979/180.0
sin(F*direct_rot*(360.0/(Eframe-Sframe))*cycle + row_interval*NO - interval*OB)*rad2deg * volume * TC"
		
		obtree =  for i in execute("$"+ob.name+"...*") collect i
		for i=1 to obtree.count do 
		(
			--add rotationlist
			rlist= Rotation_List()
			obtree[i].rotation.controller = rlist
			obtree[i].rotation.controller.Available.controller= Euler_XYZ()
			--  variables
			Ob= ("OB = " + i as string+"\n") as string
			TC= ("TC = " + (0.1*i) as string+"\n") as string
			NO= ("NO = " + no as string +"\n") as string
			--createfloatscript
			xctr = float_script()
			yctr = float_script()
			zctr = float_script()
			
			--add floatscript
			rlist[2][1].controller = xctr
			rlist[2][2].controller = yctr
			rlist[2][3].controller = zctr
			--define float script
			
			addTarget rlist[2][1].controller tar
			addTarget rlist[2][2].controller tar
			addTarget rlist[2][3].controller tar
			yscript = Ob + TC + NO+ baseYScript
			zscript = Ob + TC + NO+ baseZScript
			yctr.script = yscript
			zctr.script = zscript
		)
	)
)

fn SwayArray ls no tar offset:0 =
(
	if (ls!=undefined) and ls.count>0 do
	(
		--baseScript
		baseYScript =  "if reverse then direct_rot = -1
else direct_rot = 1
rad2deg = 3.14159265358979/180.0
sin(F*direct_rot*(360.0/(Eframe-Sframe))*cycle + row_interval*NO - interval*OB)*rad2deg * volume * TC"
baseZScript = "if reverse then direct_rot = -1
else direct_rot = 1
rad2deg = 3.14159265358979/180.0
sin(F*direct_rot*(360.0/(Eframe-Sframe))*cycle + row_interval*NO - interval*OB)*rad2deg * volume * TC"
		NO= ("NO = " + no as string +"\n") as string
		for i=1 to ls.count do 
		(
			--add rotationlist
			ls[i].rotation.controller =Euler_XYZ()
			rlist= Rotation_List()
			ls[i].rotation.controller = rlist
			ls[i].rotation.controller.Available.controller= Euler_XYZ()
			--  variables
			Ob= ("OB = " + (i+offset) as string+"\n") as string
			TC= ("TC = " + (0.1*i) as string+"\n") as string
			
			--createfloatscript
			xctr = float_script()
			yctr = float_script()
			zctr = float_script()
			
			--add floatscript
			rlist.setname 2 "Loop"
			rlist[2][1].controller = xctr
			rlist[2][2].controller = yctr
			rlist[2][3].controller = zctr
			--define float script
			
			addTarget rlist[2][1].controller tar
			addTarget rlist[2][2].controller tar
			addTarget rlist[2][3].controller tar
			yscript = Ob + TC + NO+ baseYScript
			zscript = Ob + TC + NO+ baseZScript
			yctr.script = yscript
			zctr.script = zscript
		)
	)
)

 -- add Modifier contain Sway customparameter
fn AddSwayControl no na =
(
	if (isvalidnode no) do
	(
	addModifier no (EmptyModifier ())
	CusAttr= no.modifiers[1]
	CusAttr.name =na
	Sway_def = attributes Custom_Attributes
	(
		Parameters main rollout:params
		(
			startframe type:#integer ui:sframe default:0
			Endframe type:#integer ui:eframe default:60
			Cycle type:#integer ui:cy default:2
			Volume type:#float ui:vol default:0
			Reverse type:#boolean ui:rev default:false
			Interval type:#float ui:inter default:25
			RowInterval type:#float ui:Rointer default:30
			YZtiming type:#float ui:yz default:60
		)
		rollout params "Custom Attributes"
		(
			spinner sframe "Start Frame" type:#integer align:#center
			spinner eframe "End Frame" type:#integer align:#center
			spinner cy "Cycle" type:#integer align:#center
			spinner vol "Volume"range:[-99999,99999,0] type:#float align:#center
			checkbox rev "Reverse" type:#boolean align:#center
			spinner inter "Interval" range:[-99999,99999,25] type:#float align:#center
			spinner Rointer "RowInterval" range:[-99999,99999,30] type:#float align:#center
			spinner yz "YZtiming" range:[-99999,99999,60] type:#float align:#center
		)
	)
	CustAttributes.add CusAttr Sway_Def
	)
)

-- make rollout to controlmod
fn Controlmod tar =
(
	
	try (CloseRolloutFloater SmodControl_RF) catch()
	rollout SmodCtr "Sway mod control"
		(
			spinner sframe "Start Frame" type:#integer align:#center
			spinner eframe "End Frame" type:#integer align:#center
			spinner cy "Cycle" type:#integer align:#center
			spinner vol "Volume" type:#float align:#center
			checkbox rev "Reverse" type:#boolean align:#center
			spinner inter "Interval" type:#float align:#center
			spinner Rointer "RowInterval" type:#float align:#center
			spinner yz "YZtiming" type:#float align:#center
			on sframe changed do
			(
				sctr.Custom_Attributes[1] =sframe.value
			)
			on eframe changed do
			(
				sctr.Custom_Attributes[2] =eframe.value
			)
			on cy changed do
			(
				sctr.Custom_Attributes[3] =cy.value
			)
			on vol changed do
			(
				sctr.Custom_Attributes[4] =vol.value
			)
			on rev changed do
			(
				sctr.Custom_Attributes[5] =rev.state
			)
			on inter changed do
			(
				sctr.Custom_Attributes[6] =inter.value
			)
			on Rointer changed do
			(
				sctr.Custom_Attributes[7] =Rointer.value
			)
			on yz changed do
			(
				sctr.Custom_Attributes[8] =yz.value
			)
		)
	SmodControl_RF = newrolloutfloater "Sway Mod control" 200 210 
	addRollout SmodCtr SmodControl_RF rolledUp:false
)

-- createBone from position Array
fn BonesFromArray ar bonewidth:5 boneTaper:20 upnode:undefined axis: [0,0,1] name:"SwayBone_" wirecolor:green =
(
	total = ar.count
	Sposlist = copy ar #nomap
	EposList = copy ar #nomap
	deleteItem Sposlist total
	deleteItem Eposlist 1
	bonels =#()
	for i =1 to (total-1) do
	(
		posLs = #(SposList[i],EposList[i])
		if upnode!= undefined then
		(
			alignvector =(normalize(posLs[1]-upnode.pos))
			crossvector = cross alignvector axis
			bo = BoneSys.createBone posLs[1] posLs[2] crossvector
		) else
		(
			bo = BoneSys.createBone posLs[1] posLs[2] axis
		)
		append bonels bo
		if i != 1 do
		(
			bo.parent=bonels[i-1]
		)
		bo.wirecolor = wirecolor
		bo.name = (uniquename name)
	)
	bonels.frontfin=on
	bonels.width=bonewidth
	bonels.height=bonewidth
	bonels.Taper = boneTaper
	lastbone = copy bonels[total-1]
	append bonels lastbone
	lastbone.length = lastbone.width
	lastbone.wirecolor = wirecolor
	lastbone.pos = Eposlist[total-1]
	lastbone.parent=bonels[total-1]
	bonels
)

-- createBone from Vert selection
fn BoneFromVerts ob inverts:true upnode:undefined  =
(
	vertlist = (polyop.getVertSelection ob) as array 
	if vertlist.count >2 do
	(
		vertposlist = for i in vertlist collect polyop.getVert ob i
		if inverts do reverseArray vertposlist
		bonels = BonesFromArray vertposlist  upnode:upnode
		bonels
	)
)
fn BoneFromSpline sp upnode:undefined =
(
	if (isvalidnode sp) and superclassOf sp == shape do
	(
		for s = 1 to (numSplines sp) do
		(
			Knotcount = numKnots sp s
			KnotposList = #()
			for k=1 to Knotcount do
			(
				Knotpos = getKnotPoint sp s k
				append KnotposList Knotpos
			)
			bonels = BonesFromArray KnotposLIst upnode:upnode
			bonels
		)
	)
)

-- create Bone chain root point
mapped fn CreateRoot ls size:2 type:#Point axis:#z wirecolor:yellow =
(
	if ls!= undefined do
	(
		exparent = ls.parent
		na= ls.name+"_root"
		boRoot = case type of
		(
		#Point: Point box:true size:size
		#Circle: Circle radius:size
		#CircleHalf: CreateHalftCircleHelper size 1 0
		#Circle3: CreateCircleHelper size 3 (size/10.0)
		#Circle3Half: CreateHalftCircleHelper size 3 (size/10.0)
		#Sphere: CreateSphereHelper size
		default: Point box:true size:size
		)
		if (classof boRoot)!= Point do
		(
			case axis of
			(
			1: rotate boRoot (angleaxis -90 [1,0,0])
			2: (rotate boRoot (angleaxis 90 [0,0,1]);rotate boRoot (angleaxis 90 [0,1,0]))
			3: rotate boRoot (angleaxis -90 [0,1,0])
			4: rotate boRoot (angleaxis 90 [1,0,0])
			5: (rotate boRoot (angleaxis -90 [0,0,1]);rotate boRoot (angleaxis 90 [0,1,0]))
			6: rotate boRoot (angleaxis 90 [0,1,0])
			)
			resetXform boRoot
			collapseStack boRoot
		)
		boRoot.pos = ls.pos
		boRoot.wirecolor=wirecolor
		boRoot.name=na
		MatchRotation boRoot ls
		ls.parent = boRoot
		boRoot.parent = exparent
		addmodifier boRoot (EmptyModifier ())
		boRoot
	)
)
fn CreateHelper type:#Point size:2 wirecolor:yellow = 
(
	boRoot = case type of
	(
	#Point: Point box:true size:size
	#Circle: Circle radius:(size*2)
	#CircleHalf: CreateHalftCircleHelper (size*2) 1 0
	#Circle3: CreateCircleHelper (size*2) 3 (size/10.0)
	#Circle3Half: CreateHalftCircleHelper (size*2) 3 (size/10.0)
	#Sphere: CreateSphereHelper size
	default: Point box:true
	)
	boRoot.wirecolor = wirecolor
	boRoot.name = (type as string) +"_Root"
	addmodifier boRoot (EmptyModifier ())
	boRoot
)
--RemoveRoot
mapped fn RemoveRoot ob=
(
	if ob!= undefined do
	(
	exchildren = #()
	for c in ob.children do append exchildren c
	exparent = ob.parent
	delete ob
	for i in exchildren do i.parent = exparent
	)
)
--extra
rollout rlInfo "Information"
(
	label lbColor "Display Color:" pos:[10,13]
	dropdownlist dlColor items:#("wirecolor","red", "green", "blue", "white", "black", "yellow", "orange") width:70 pos:[80,10]
	label lbType "Display Type:" pos:[10,45]
	dropdownlist dlType items:#("Selection","Scene") width:70 pos:[80,42]
	label lbHidden "Show Hidden:" pos:[10,75]	
	checkbox cbHidden "" pos:[80,75]
	groupbox gpParameters "Parameters" width:140 height:205 pos:[10,100]
 	checkbutton btnObjectName "Object Name" width:120 height:25 pos:[20,120]
	checkbutton btnObjectID "Object Transform Type" width:120 height:25 pos:[20,145]
	--checkbutton btnObjectID "Object ID" width:120 height:25 pos:[20,145]
	checkbutton btnObjectParent "Parents Names" width:120 height:25 pos:[20,170]
	checkbutton btnParentConnections "Parent Connections" width:120 height:25 pos:[20,195]
	checkbutton btnPolyCount "Poly Count" width:120 height:25 pos:[20,220] 
	checkbutton btnDimensionsGlobal "Dimensions" width:120 height:25 pos:[20,245]
	checkbutton btnDimensionsSubobject "Sub Dimensions" width:120 height:25 pos:[20,270] checked:true

	-- general functions
	fn GetVertsBoundingBox obj:undefined verts:#() =
	(
		bb = #([0,0,0] , [0,0,0])
		if not verts.count >= 2 do return bb
		
		-- store the values for each axis
		ptsX = #()
		ptsY = #()
		ptsZ = #()
		
		-- operation method
		op = if classof obj == Editable_Poly then polyop else meshop
			
		for v in verts do
		(	
			pt = op.getVert obj v
			append ptsX pt.x
			append ptsY pt.y
			append ptsZ pt.z
		)
		
		if not ptsX.count >= 2 do return bb
		if not ptsY.count >= 2 do return bb
		if not ptsZ.count >= 2 do return bb
			
		-- sort points low to high
		sort ptsX
		sort ptsY
		sort ptsZ
		
		-- min/max
		bb[1] = [ptsX[1]  , ptsY[1], ptsZ[1]] 
		bb[2] = [ptsX[ptsX.count]  , ptsY[ptsY.count], ptsZ[ptsZ.count]] 
		
		return bb
	)

	fn GetSubObjectBoundingBox =
	(
		local bb = #([0,0,0], [0,0,0])
		
		if selection.count != 1 do return bb
		if (getCommandPanelTaskMode()) != #modify do return bb
			
		obj = selection[1]	
		if classof obj != Editable_Poly AND classof obj != Editable_Mesh do return bb
		
		-- operation method
		op = if classof obj == Editable_Poly then polyop else meshop
			
		case (getSelectionLevel obj) of
		(
			#vertex:
			(
				verts = (if classof obj == Editable_Poly then op.getVertSelection  else getVertSelection) obj
				bb = GetVertsBoundingBox obj:obj verts:verts
			)
			#edge:
			(
				edges = (if classof obj == Editable_Poly then op.getEdgeSelection  else getEdgeSelection) obj
				verts = op.getVertsUsingEdge obj edges
				bb = GetVertsBoundingBox obj:obj verts:verts
			)
			#face:
			(
				faces = (if classof obj == Editable_Poly then op.getFaceSelection  else getFaceSelection) obj
				verts = op.getVertsUsingFace obj faces
				bb = GetVertsBoundingBox obj:obj verts:verts
			)
		)

		return bb
	)
	
	-- display functions
	fn fnDisClr o = (
		selColor = dlColor.items[(dlColor.selection)]
		if selColor == "wirecolor" do (return o.wirecolor)
		if selColor == "red" do return red
		if selColor == "green" do return green
		if selColor == "blue" do return blue
		if selColor == "white" do return white
		if selColor == "black" do return black
		if selColor == "yellow" do return yellow
		if selColor == "orange" do return orange
	)
	
	fn userNodes = (
		selType = dlType.items[(dlType.selection)]
		col = if selType == "Selection" then Selection else Objects
		_theNodes = if cbHidden.state then col else (for o in col where not o.isHiddenInVpt collect o)
		return _theNodes
	)
	
	fn showObjectNames = if (gw.wTransPoint [0,0,0]) != undefined do (
		gw.setTransform (Matrix3 1)
		
		for o in (userNodes()) do
		(
			pos = gw.wTransPoint o.transform.translation
			pos.z = 0
			gw.wtext pos o.name color:(fnDisClr o)
		)
		gw.enlargeUpdateRect #whole
		gw.updateScreen()
	)
	fn showObjectID = if (gw.wTransPoint [0,0,0]) != undefined do (
		gw.setTransform (Matrix3 1)
		for o in (userNodes()) do
		(
			pos = gw.wTransPoint o.transform.translation
			pos.z = 0
			gw.wtext pos (o.gbufferchannel as string) color:(fnDisClr o)
		)
		gw.enlargeUpdateRect #whole
		gw.updateScreen()
	)
	fn showObjectParent = if (gw.wTransPoint [0,0,0]) != undefined do (
		gw.setTransform (Matrix3 1)
		for o in (userNodes()) do
		(
			pos = gw.wTransPoint o.transform.translation
			pos.z = 0
			info = if o.parent != undefined then o.parent.name else "!"
			clr = if o.parent != undefined then (fnDisClr o.parent) else (fnDisClr o)
			gw.wtext pos info color:clr
		)
		gw.enlargeUpdateRect #whole
		gw.updateScreen()
	)
	fn showTransformType = if (gw.wTransPoint [0,0,0]) != undefined do (
		gw.setTransform (Matrix3 1)
		for o in (userNodes()) do
		(
			if (classof o!= Biped_Object) then
			(
			pos = gw.wTransPoint o.transform.translation
			pos.z = 0
			posinfo = (classof o.position.controller) as string
			rotinfo =  (classof o.rotation.controller) as string
			scaleinfo =  (classof o.scale.controller) as string
			info = posinfo +"\n"+rotinfo+"\n" +scaleinfo
			gw.wtext pos info color:(fnDisClr o)
			) else 
			(
				pos = gw.wTransPoint o.transform.translation
				pos.z = 0
				info = (Classof o) as string
				gw.wtext pos info color:(fnDisClr o)
			)
		)
		gw.enlargeUpdateRect #whole
		gw.updateScreen()
	)
	fn showParentConnections = if (gw.wTransPoint [0,0,0]) != undefined do (
		gw.setTransform (Matrix3 1)
		for o in (userNodes()) do
		(
			pos = gw.wTransPoint o.transform.translation
			pos.z = 0
			if o.parent != undefined do (
				gw.setColor #line (o.parent.wirecolor)
				gw.Polyline #(o.transform.translation,o.parent.transform.translation) true
			)
		)
		gw.enlargeUpdateRect #whole
		gw.updateScreen()
	)
	fn showObjectPolyCount = if (gw.wTransPoint [0,0,0]) != undefined do (
		gw.setTransform (Matrix3 1)
		
		for o in (userNodes()) where superclassof o == GeometryClass do
		(
			polyCount = o.mesh.numfaces as string
			pos = gw.wTransPoint o.transform.translation
			pos.z = 0
			gw.wtext pos polyCount color:(fnDisClr o)
		)
		gw.enlargeUpdateRect #whole
		gw.updateScreen()
	)
	fn showObjectDimensionsGlobal = if (gw.wTransPoint [0,0,0]) != undefined do (
		gw.setTransform (Matrix3 1)
		for o in (userNodes()) do
		(
			--nodeLocalBoundingBox $ -- local
			bb = nodeGetBoundingBox o (matrix3 1)
			
			-- corner points
			topA = [bb[1].x , bb[1].y, bb[2].z]
			bottomA = bb[1]
			bottomB = [bb[2].x , bb[1].y, bb[1].z]
			bottomC = [bb[1].x , bb[2].y, bb[1].z]

 			-- height
 			hLength = distance bottomA topA 
 			hCenter = (bottomA + topA) / 2.0
 			pos = gw.wTransPoint hCenter
 			gw.setColor #line ((fnDisClr o) / 2.0)
 			gw.Polyline #(bottomA, topA) true
 			gw.wtext pos (hLength as string) color:(fnDisClr o)

 			-- width
			wLength = distance bottomA bottomB 
 			wCenter = (bottomA + bottomB) / 2.0
 			pos = gw.wTransPoint wCenter
 			gw.setColor #line ((fnDisClr o) / 2.0)
 			gw.Polyline #(bottomA, bottomB) true
 			gw.wtext pos (wLength as string) color:(fnDisClr o)

 			-- length
			lLength = distance bottomA bottomC 
 			lCenter = (bottomA + bottomC) / 2.0
 			pos = gw.wTransPoint lCenter
 			gw.setColor #line ((fnDisClr o) / 2.0)
 			gw.Polyline #(bottomA, bottomC) true
 			gw.wtext pos (lLength as string) color:(fnDisClr o)
		)
		gw.enlargeUpdateRect #whole
		gw.updateScreen()
	)

	fn showObjectDimensionsSubObject = if (gw.wTransPoint [0,0,0]) != undefined do 
	(
		gw.setTransform (Matrix3 1)
		
		for o in (userNodes()) do
		(
			bb = GetSubObjectBoundingBox()
			
			-- corner points
			topA = [bb[1].x , bb[1].y, bb[2].z]
			bottomA = bb[1]
			bottomB = [bb[2].x , bb[1].y, bb[1].z]
			bottomC = [bb[1].x , bb[2].y, bb[1].z]

			-- height
			hLength = distance bottomA topA 
			hCenter = (bottomA + topA) / 2.0
			pos = gw.wTransPoint hCenter
			gw.setColor #line ((fnDisClr o) / 2.0)
			gw.Polyline #(bottomA, topA) true
			gw.wtext pos (hLength as string) color:(fnDisClr o)

			-- width
			wLength = distance bottomA bottomB 
			wCenter = (bottomA + bottomB) / 2.0
			pos = gw.wTransPoint wCenter
			gw.setColor #line ((fnDisClr o) / 2.0)
			gw.Polyline #(bottomA, bottomB) true
			gw.wtext pos (wLength as string) color:(fnDisClr o)

			-- length
			lLength = distance bottomA bottomC 
			lCenter = (bottomA + bottomC) / 2.0
			pos = gw.wTransPoint lCenter
			gw.setColor #line ((fnDisClr o) / 2.0)
			gw.Polyline #(bottomA, bottomC) true
			gw.wtext pos (lLength as string) color:(fnDisClr o)
		)
		gw.enlargeUpdateRect #whole
		gw.updateScreen()
	)

	fn updateInfo = 
	(
		if btnObjectName.state then 
		(
			unRegisterRedrawViewsCallback showObjectNames
			forceCompleteRedraw()
			registerRedrawViewsCallback showObjectNames
			forceCompleteRedraw()
		)
		if btnObjectID.state then 
		(
			unRegisterRedrawViewsCallback showObjectID
			forceCompleteRedraw()
			registerRedrawViewsCallback showObjectID
			forceCompleteRedraw()
		)
		if btnObjectParent.state then 
		(
			unRegisterRedrawViewsCallback showObjectParent
			forceCompleteRedraw()
			registerRedrawViewsCallback showObjectParent
			forceCompleteRedraw()
		)
		if btnParentConnections.state then 
		(
			unRegisterRedrawViewsCallback showParentConnections
			forceCompleteRedraw()
			registerRedrawViewsCallback showParentConnections
			forceCompleteRedraw()
		)
		if btnPolyCount.state then 
		(
			unRegisterRedrawViewsCallback showObjectPolyCount
			forceCompleteRedraw()
			registerRedrawViewsCallback showObjectPolyCount
			forceCompleteRedraw()
		)
		if btnDimensionsGlobal.state then 
		(
			unRegisterRedrawViewsCallback showObjectDimensionsGlobal
			forceCompleteRedraw()
			registerRedrawViewsCallback showObjectDimensionsGlobal
			forceCompleteRedraw()
		)
		if btnDimensionsSubobject.state then
		(
			unRegisterRedrawViewsCallback showObjectDimensionsSubObject
			forceCompleteRedraw()
			registerRedrawViewsCallback showObjectDimensionsSubObject
			forceCompleteRedraw()
		)
	)
	
	on btnObjectName changed state do 
	(
		(if state then registerRedrawViewsCallback else unRegisterRedrawViewsCallback) showObjectNames
		forceCompleteRedraw()
	)
	on btnObjectID changed state do 
	(
		(if state then registerRedrawViewsCallback else unRegisterRedrawViewsCallback) showTransformType
		forceCompleteRedraw()
	)
	on btnObjectParent changed state do 
	(
		(if state then registerRedrawViewsCallback else unRegisterRedrawViewsCallback) showObjectParent
		forceCompleteRedraw()
	)
	on btnParentConnections changed state do 
	(
		(if state then registerRedrawViewsCallback else unRegisterRedrawViewsCallback) showParentConnections
		forceCompleteRedraw()
	)
	on btnPolyCount changed state do 
	(
		(if state then registerRedrawViewsCallback else unRegisterRedrawViewsCallback) showObjectPolyCount
		forceCompleteRedraw()
	)
	on btnDimensionsGlobal changed state do 
	(
		(if state then registerRedrawViewsCallback else unRegisterRedrawViewsCallback) showObjectDimensionsGlobal
		forceCompleteRedraw()
	)
	on btnDimensionsSubobject changed state do 
	(
		(if state then registerRedrawViewsCallback else unRegisterRedrawViewsCallback) showObjectDimensionsSubObject
		forceCompleteRedraw()
	)
	on cbHidden changed state do (updateInfo())
	on dlColor selected idx do (updateInfo())
	on dlType selected idx do (updateInfo())
	on rlInfo open do (updateInfo())
	on rlInfo close do 
	(
		unRegisterRedrawViewsCallback showObjectNames
		unRegisterRedrawViewsCallback showObjectID
		unRegisterRedrawViewsCallback showObjectParent
		unRegisterRedrawViewsCallback showTransformType
		unRegisterRedrawViewsCallback showParentConnections
		unRegisterRedrawViewsCallback showObjectPolyCount
		unRegisterRedrawViewsCallback showObjectDimensionsGlobal
		unRegisterRedrawViewsCallback showObjectDimensionsSubObject
	)
)