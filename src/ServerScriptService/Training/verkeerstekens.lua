-- ModuleScript: ServerScriptService > Training > verkeerstekens
return {
	kind = "sign",
	options = {
		"Voorrangsweg", "Einde voorrangsweg",
		"Verleen voorrang aan bestuurders op de kruisende weg",
		"Stop; verleen voorrang aan bestuurders op de kruisende weg",
	},
	questions = {
		{ id = "sign_b6_01", signCode = "B6", correct = 3 },
		{ id = "sign_b1_01", signCode = "B1", correct = 1 },
		{ id = "sign_b7_01", signCode = "B7", correct = 4 },
		{ id = "sign_b2_01", signCode = "B2", correct = 2 },
	},
}
