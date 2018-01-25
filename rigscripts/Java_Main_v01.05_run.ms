--import
fileIn "rigscripts/libs.ms"
--main
clearListener()
try (CloseRolloutFloater JavaRig_RF) catch()
--var
global CHname =""
global SwayCtr =undefined
global SwayCtrmods =#()
global RF_width = 200 --Define RolloutFloater Width
global RF_height = 750 --Define RolloutFloater Height
fn getCHname =
(
	if maxFilename !="" do
	(
		maxnamestrlist= filterstring maxFileName "_"
		if maxnamestrlist.count >2 then CHname =maxnamestrlist[2] else CHname =maxfilename
		SwayCtrname = (Chname +"_ond_sway")
		if isvalidnode (getnodebyname SwayCtrname) do
		(
		SwayCtr = getnodebyname SwayCtrname
		SwayCtrmods =for i in SwayCtr.modifiers collect i.name
		)
	)
)
getCHname()
-- local function


--UI def
rollout MainUI "Main"
(
	imgtag splash bitmap:(openbitmap ((getDir #scripts)+"\javascripts\icons\Splash.png")) width:160 height:20
	label chnamelabel "Character name:" align:#left
	edittext Chnamebt align:#left text:CHname
	button UpdateScenebt "Update Name" width:100 height:30
	on UpdateScenebt pressed do
	(
		getCHname()
		Chnamebt.text= Chname
	)
)
rollout RigCreationUI "RigCreationTool"
(
	--UI
	button CreateCtr "CreateSwayCtrl" width:100 height:30
	edittext  boname "name:" text:"--Sway Controller name--"
	group "Bone Creation Tools:"
	(
		button botools "Bone Tools" width:80 height:30
		label bomlabel "Bone name:" align:#left
		edittext  bonamete align:#left text:"__bonename"
		spinner bocolnum range:[0,100,0] type:#integer align:#right  width:35 height:20
		button renamebobt "Rename" align:#right  width:50 height:30 offset:[-40,-25]
		label bocolorlabel "Bone Color:" align:#left
		colorpicker BOneColorbt color:[0,0255,0] modal:false align:#center width:50 height:20 offset:[0,-15]
		button recolorbobt "Apply" align:#right width:50 height:20 offset:[0,-25]
		button ObtoBonebt "ObjectstoBone" align:#left
		checkbox DeleteSelbt "Delete $" align:#right offset:[0,-25] height:20
		button drawsp "DrawSpline" align:#left width:70  height:20
		spinner disValue "Distance" range:[0,100,10] type:#integer align:#right width:60 height:20 offset:[0,-25]
		button Sptobo "SplinetoBone" align:#left width:70  height:20
		spinner bonumValue "# bones" range:[0,100,5] type:#integer align:#right  width:60 height:20 offset:[0,-25]
		Button makeStrechBonebt "Make Strech Bones" align:#left
		checkbox isLoopbt "Loop" align:#right offset:[0,-25] height:20
	)
	group "Create Helper:"
	(
		editText ponnamete "Helper Name" text:"--Helper name--"
		dropdownlist roottypelist "Type" items:#("Point","Circle","CircleHalf","Circle3","Circle3Half","Sphere") width:100 height:20
		spinner borootsizesp "Size" range:[0,10000,10] type:#float width:50 height:20 offset:[30,-45]
		colorpicker Colorbt "Color:" color:[255,255,0] modal:false width:55 height:20 align:#right  offset:[5,-5]
		radiobuttons axispick columns:3 labels:#("x","y","z","-x","-y","-z")default:3 width:160 height:30 visible:true offset:[0,0]
		radiobuttons pointstate columns:1 labels:#("Standalone","Root of selection","Children of selection","Transform instance to selection","Position instance to selection","Attach to selected Vert") \
		align:#left
		
		button createRootbt "Create" tooltip:"RightClick to create on selected vertices" width:60 height:30 align:#left
		button Modsizebt "Modify" tooltip:"RightClick to create on Delete without Breaking Hieachy" width:60 height:30 align:#left offset:[70,-35]
	)

	--Function
	on renamebobt pressed do
	(
		if selection.count !=0 do
		(
			for i=1 to selection.count do
			(
				if bocolnum != 0 then
				(
					$[i].name = (bonamete.text+"_"+bocolnum.value as string+"_"+"0"+i as string)
				) else $[i].name = (bonamete.text+"_"+"0"+i as string)
			)
		) 
	)
	on recolorbobt pressed do
	(
		for i in selection do
		(
			if (isvalidnode i) do
			(
				i.wirecolor = bonecolorbt.color
			)
		)
	)
	on ObtoBonebt pressed do
	(
		if selection.count >=2 then
		(
			poslist = for i in selection collect i.transform.translation
			BonesFromArray poslist
			if deleteSelbt.checked do delete selection
		)else messageBox "Select 2 or more Object"
	)
	on makeStrechBonebt pressed do
	(
		if selection.count >=2 then makeStrechBone loop:isLoopbt.checked else createStretchBone [0,0,0] [20,0,0]
	)
	on CreateCtr pressed do
	(
		if SwayCtr == undefined then
		(
			if MainUI.chnamebt.text!= "" then
			(
				strlist = filterstring MainUI.chnamebt.text "-"
				ctrname= MainUI.chnamebt.text +"_ond_sway"
				ctrtext = (substring strlist[2] 1 (strlist[2].count-1)) +"-Sway"
				SwayCtr = createControlText ctrname ctrtext
				select SwayCtr
			) else
			(
				SwayCtr = createControlText boname.text "Sway Controller"
			)
		) else select SwayCtr
	)
	on drawsp pressed do
	(
		drawSpline dis:disValue.value
	)
	on Sptobo pressed do
	(
		for i in selection do
		(
			for s = 1 to (numSplines i) do
			(
				pls = #()
				kcount = boNumvalue.value
				for k=1 to (kcount+1) do
				(
					kpos=interpCurve3D i s ((k-1)*(1.0/kcount))
					append pls kpos
				)
				BonesFromArray pls
			)
		)
	)
	on botools pressed do
	(
		macros.run "Animation Tools" "BoneAdjustmentTools"
	)
	fn makeRootHelper =
	(
		axis = axispick.state
			CreateRoot $ type:(roottypelist.selected as name) axis:axis size:borootsizesp.value wirecolor:colorbt.color
	)
	fn makeChildHelper =
	(
		if selection.count!= 0 then
			(
				for o in selection do
				(
					if (isvalidnode o) do
					(
						oldchild = o.children
						pointob = CreateHelper type:(roottypelist.selected as name) size:borootsizesp.value wirecolor:colorbt.color
						pointob.pos=o.pos
						for ob in oldchild do ob.parent = pointob
						pointob.parent =o
					)
				)
			)
	)
	fn makeInstancetransformHelper = 
	(
		if selection.count != 0 then
			(
				for i in selection do
				(
					rootob = CreateHelper type:(roottypelist.selected as name) size:borootsizesp.value wirecolor:colorbt.color
					rootob.pos = i.pos
					rootob.controller = i.controller
					--if inposcb.checked do rootob.position.controller = i.position.controller
				)
			) else CreateHeslper type:(roottypelist.selected as name) size:borootsizesp.value wirecolor:colorbt.color
	)
	fn makeInstancePositionHelper =
	(
		if selection.count != 0 then
			(
				for i in selection do
				(
					rootob = CreateHelper type:(roottypelist.selected as name) size:borootsizesp.value wirecolor:colorbt.color
					rootob.pos = i.pos
					--if intrcb.checked do rootob.controller = i.controller
					rootob.position.controller = i.position.controller
				)
			) else CreateHeslper type:(roottypelist.selected as name) size:borootsizesp.value wirecolor:colorbt.color
	)
	fn makeAttachHelper =
	(
		if selection.count ==1 and (classof $) == Editable_mesh or (classof $) == Editable_Poly do
			(
				pointob = PointAttachtoMesh $
				tempob = CreateHelper type:(roottypelist.selected as name) size:borootsizesp.value wirecolor:colorbt.color
				for p in pointob do
				(
					if (classof tempob)!= Point do 
					(
						p.baseobject = tempob.baseobject
						p.wirecolor = tempob.wirecolor
						p.name = tempob.name
					)
				)
				delete tempob
			)
	)
	fn makeHelper =
	(
		if selection.count != 0 then
		(
			for o in selection do
			(
			pointob=CreateHelper type:(roottypelist.selected as name) size:borootsizesp.value wirecolor:colorbt.color
			pointob.transform = o.transform
			)
		) else CreateHelper type:(roottypelist.selected as name) size:borootsizesp.value wirecolor:colorbt.color
	)
	on createRootbt pressed do
	(
		case pointstate.state of
		(
			1: makeHelper()
			2: makeRootHelper()
			3: makeChildHelper()
			4: makeinstanceTransformHelper()
			5: makeinstancePositionHelper()
			6: makeAttachHelper()
		)
	)
	on createRootbt rightclick do
	(
		if $!= undefined do
		(
			temphelper= CreateHelper type:(roottypelist.selected as name) size:borootsizesp.value wirecolor:colorbt.color
			HelperArrays = PointAttachtomesh $
			for i in HelperArrays do
			(
				if (classof tempHelper)!= Point then i.baseObject = temphelper else i.size=temphelper.size
				i.wirecolor = temphelper.wirecolor
				i.name = uniquename temphelper.name
				if attachcb.checked ==false do i.position.controller=position_XYZ()
			)
			delete temphelper
		)
	)
	on modsizebt pressed do
	(
		if selection.count != 0 do
		(
			for i in selection do
			(
				if (superclassof i) == Helper or (Superclassof i) == shape then
				(
					tempOb =  CreateHelper type:(roottypelist.selected as name) size:borootsizesp.value wirecolor:colorbt.color
					i.baseobject =tempOb.baseobject
					i.wirecolor=tempOb.wirecolor
					delete tempOb
				)
			)
		)
	)
	on modsizebt rightclick do
	(
		RemoveRoot $
	)
)
Rollout RigmanageUI "Rig Management Tool"
(
	--Ui
	label palabel "Apply Parent:" align:#left
	edittext  panametx align:#left text:"_no Target"
	pickbutton pickpa "Pick Parent"align:#left width:105 height:20
	button linkpa "Apply" align:#right width:50 height:20 offset:[0,-25]
	label lalabel "Apply Lookat:" align:#left
	edittext  lanametx align:#left text:"_no Target"
	pickbutton picklabt "Pick Target" align:#left width:105 height:20
	pickbutton pickunbt "Pick Upnode" align:#left width:105 height:20
	button lookatbt "Apply" align:#right width:50 height:50 offset:[0,-50]
	spinner viewlengthspinner "LA ViewLenght" align:#left
	--Function
	on viewlengthspinner changed val do
	(
		for i in selection do
		(
			if (classof i.rotation.controller) == Lookat_constraint do
			(
				i.rotation.controller.lookat_vector_length = val
			)
		)
	)
	on pickpa picked ob do
	(
			panametx.text = ob.name
	)
	on linkpa pressed do
	(
		if pickpa.object != undefined do
		(
			for i in selection do
			(
				undo on 
				(
				i.parent= pickpa.object
				)
			)
		)
	)
	
	on picklabt picked ob do
	(
			lanametx.text = ob.name
	)
	on pickunbt picked ob do
	(
			pickunbt.text = ob.name
	)
	on lookatbt pressed do
	(
		undo on
		(
		addLookAt selection picklabt.object upnode:pickunbt.object
		)
	)
	
)
RollOut SwayUi "Make Bone Sway Tool"
(
	--UI

	label swnamelabel "Sway modifiers:" align:#left
	dropdownlist moddroplist items:SwayCtrmods selection:1 width:100 height:20 pos:[15,30]
	edittext  Smname align:#left text:"Sway Atrribute" width:100
	button updatemodlsbt "reload" align:#left pos:[120,5] width:50 height:20
	button addmodbt "AddThis" align:#left pos:[115,55] width:60 height:20
	button openmodbt "ControlThis" align:#right pos:[115,30] width:60 height:20
	label seplabel1 "----------------------------------------" align:#left pos:[15,80]
	spinner noValue "NO" range:[0,100,1] type:#integer align:#right pos:[127,100] width:45 height:20
	spinner obValue "OB offset" range:[0,100,0] type:#integer align:#right pos:[114,120] width:58 height:20
	button makeswaybt "Sway It" tooltip:"when marimba rhythms start to play" align:#left pos:[15,100] width:65 height:40
	
	--Function
	on addmodbt pressed do
	(
		if SwayCtr!=undefined and (not validmodifier SwayCtr SwayCtr.modifiers[smname.text as name]) do
		(
			AddSwayControl SwayCtr smname.text
		)
		SwayCtrmods = for i in SwayCtr.modifiers collect i.name
		moddroplist.items = SwayCtrmods
	)
	on makeswaybt pressed do
	(
		if SwayCtr!=undefined and (validmodifier SwayCtr SwayCtr.modifiers[moddroplist.selected as name]) do
		(
			SwayCtr.modifiers[moddroplist.selected as name].Custom_Attributes.volume = 0
			modtarget = SwayCtr.modifiers[moddroplist.selected as name]
			SwayArray selection noValue.value modtarget offset:obvalue.value
		)
	)
	on openmodbt pressed do
	(
		max modify mode
		if validmodifier SwayCtr SwayCtr.modifiers[moddroplist.selected as name] do
		(
			modPanel.setCurrentObject SwayCtr.modifiers[moddroplist.selected as name]
		)
	)
	on updatemodlsbt pressed do
	(
		SwayCtrmods = for i in SwayCtr.modifiers collect i.name
		moddroplist.items = SwayCtrmods
	)
)
rollout EyeRigUI "Facial Rig Tool" width:185 height:100
(
	button InsTran "Instance Transform CTR" width:150 height:20
	button InsPos "Instance Position CTR" width:150 height:20
	group "SkinWrap to Morpher Target"
	(
		pickbutton Skinwrapob "Select SkinWrap Object"  width:150 height:25
		pickbutton MorpherOb "Select Morpher Object"  width:150 height:25
		button WraptoMorphbt "Skinwrap to MorphTarget" width:150 height:30
	)
	group "EyeRig"
	(
		label eyeoblab "Select Eyes Meshes:"
		pickbutton EyeL "Select Eye Left"  width:150 height:25
		pickbutton EyeR "Select Eye Right"  width:150 height:25
		label eyeclab "Select Eyes Control:"
		pickbutton EyeMCtr "Main" width:150 height:25
		pickbutton EyeLCtr "Left"width:150 height:25
		pickbutton EyeRCtr "Right" width:150 height:25
		button WireXform "Apply" width:160 height:40
	)
	button ResetXf "ResetXform" width:150 height:35
		fn SnapshotSkinWrap sob mob offset:100 =
	(
		if sob.modifiers[#'Skin Wrap']!=undefined and mob.modifiers[#Morpher]!=undefined do
		(
			for i=1 to 100 do
			(
				if mob.modifiers[#Morpher][i].name!="- empty -" do
				(
					mob.modifiers[#Morpher][i].value = 100
					mtarget = snapshot sob
					mtarget.name = mob.modifiers[#Morpher][i].name
					move mtarget [offset*i,0,0]
				)
			)
		)
	)
	on MorpherOb picked ob do morpherOb.text = ob.name
	on Skinwrapob picked ob do Skinwrapob.text = ob.name
	on WraptoMorphbt pressed do
	(
		if MorpherOb.object != undefined and Skinwrapob.object!=undefined do SnapshotSkinWrap Skinwrapob.object MorpherOb.object
	)
	on InsTran pressed  do
	(
		if selection != undefined and selection.count>1 then
		(
			masterCtr= $[1].controller
			for i=2 to selection.count do
			(
				$[i].controller = masterCtr
			)
		) else messageBox "pick 2 or more object starting with the master"
	)
	on EyeL picked obj do
	(
		EyeL.text = obj.name
	)
	on EyeR picked obj do
	(
		EyeR.text = obj.name
	)
	on EyeMCtr picked obj do
	(
		EyeMCtr.text = obj.name
	)
	on EyeLCtr picked obj do
	(
		EyeLCtr.text = obj.name
	)
	on EyeRCtr picked obj do
	(
		EyeRCtr.text = obj.name
	)
	on InsPos pressed  do
	(
		if selection != undefined and selection.count>1 then
		(
			masterCtr= $[1].position.controller
			for i=2 to selection.count do
			(
				$[i].position.controller = masterCtr
			)
		) else messageBox "pick 2 or more object starting with the master"
	)
	on ResetXf pressed  do
	(
		xFormResetter true 1
	)
	on WireXform pressed  do
	(
		
		ELob = EyeL.object
		ERob = EyeR.object
		EMCob = EyeMCtr.object
		ELCob = EyeLCtr.object
		ERCob = EyeRCtr.object
		sLibResetXForm EMCob
		maxOps.CollapseNode EMCob on
		if EMCob.parent != undefined then 
		(
			sLibResetXForm EMCob.parent 
			maxOps.CollapseNode EMCob.parent on
		if ELob != undefined and ELCob != undefined and EMCob != undefined and ERCob != undefined then
		(
			in coordsys parent EMCobX = EMCob[3][1][1].value
			in coordsys parent EMCobZ = EMCob[3][1][3].value
			in coordsys parent ELCobX = ELCob[3][1][1].value
			in coordsys parent ELCobZ = ELCob[3][1][3].value
			in coordsys parent ERCobX = ERCob[3][1][1].value
			in coordsys parent ERCobZ = ERCob[3][1][3].value
			Ex = "X_Position-(" + EMCobX as string +")"
			Ez = "Z_Position-(" + EMCobZ as string +")"
			ExL = "X_Position-(" + ELCobX as string +")"
			EzL = "Z_Position-(" + ELCobZ as string +")"
			ExR = "X_Position-(" + ERCobX as string +")"
			EzR = "Z_Position-(" + ERCobZ as string +")"
			resetc = bezier_float ()
			tm = Elob.modifiers.count
			ELob.modifiers[#XForm][1][#X_Position].controller = resetc
			ELob.modifiers[#XForm][1][#Z_Position].controller = resetc
			ELob.modifiers[#'XForm-L'][2][1][#X_Position].controller = resetc
			ELob.modifiers[#'XForm-L'][2][1][#Z_Position].controller = resetc
			ERob.modifiers[#'XForm-R'][2][1][#X_Position].controller = resetc
			ERob.modifiers[#'XForm-R'][2][1][#Z_Position].controller = resetc
			
			if classOf ELob.modifiers[tm] ==Xform and classOf ELob.modifiers[tm-1] ==Xform then
				(
					paramWire.connect EMCob[3][1][#X_Position] ELob.modifiers[#XForm][1][#X_Position] Ex
					paramWire.connect EMCob[3][1][#Z_Position] ELob.modifiers[#XForm][1][#Z_Position] Ez
					paramWire.connect ELCob[3][1][#X_Position] ELob.modifiers[#'XForm-L'][2][1][#X_Position] ExL
					paramWire.connect ELCob[3][1][#Z_Position] ELob.modifiers[#'XForm-L'][2][1][#Z_Position] EzL
					paramWire.connect ERCob[3][1][#X_Position] ERob.modifiers[#'XForm-R'][2][1][#X_Position] ExR
					paramWire.connect ERCob[3][1][#Z_Position] ERob.modifiers[#'XForm-R'][2][1][#Z_Position] EzR
					paramWire.connect ELCob[3][3] ELob.modifiers[#'XForm-L'][2][3] "Scale"
					paramWire.connect ERCob[3][3] ERob.modifiers[#'XForm-R'][2][3] "Scale"
				) else messageBox "Eye Mehes don't have xform modifier or not in the right position"
		) else messageBox "Pick Object?"
		) else messageBox "Eye Main is not linked to headpart"
	)
)

RollOut InfoUi "Info"
(
	button sceneinfobt "SceneInfo"
	label Scrnamelabel "Java Rig Helper v0.1"
	label makerlabel "Created by Nguyen Phi Hung"
	label datelabel "2016"
	on sceneinfobt pressed do
	(
		try(destroyDialog ::rlInfo)catch()
		createDialog rlInfo 160 315 style:#(#style_SysMenu, #style_ToolWindow)
	)
)
JavaRig_RF = newrolloutfloater "Java Rig Helper" 200 750 1450 170
addRollout MainUi JavaRig_RF category:1 rolledUp:false
addRollout RigCreationUi JavaRig_RF category:2 rolledUp:true
addRollout RigManageUi JavaRig_RF category:3 rolledUp:true
addRollout SwayUi JavaRig_RF category:4 rolledUp:true
addRollout EyeRigUi JavaRig_RF category:5 rolledUp:true
addRollout InfoUi JavaRig_RF category:6
--AddSubRollout mainUI.RigCreationSubrollout RigCreationUi