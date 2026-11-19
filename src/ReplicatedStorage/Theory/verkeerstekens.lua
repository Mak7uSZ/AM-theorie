-- ModuleScript: ReplicatedStorage > Theory > verkeerstekens
return {
	topicId = "verkeerstekens",
	titleNl = "Verkeerstekens",
	sourceName = "RVV 1990 — bijlage 1 en verkeersregels",
	sourceUrl = "https://wetten.overheid.nl/BWBR0004825/#Bijlage1",
	article = "Bijlage 1 (A1, A2, B1, B2, B6, B7, C2, C13, C15, G11, G12a, G13) en artikelen 2, 2b, 5, 6, 15, 18, 20, 21, 62–64, 66, 79, 84",
	reviewStatus = "reviewed",
	images = {},
	questionIds = {
		"sign_b6_01", "sign_b1_01", "sign_b7_01", "sign_b2_01",
		"sign_g11_01", "sign_g12a_01", "sign_g13_01",
		"sign_c2_01", "sign_c13_01", "sign_c15_01",
		"sign_a1_50_01", "sign_a2_30_01", "sign_zone_30_01", "sign_end_zone_30_01",
	},
	sceneIds = {},
	-- The owner's sign explanations, edited and checked against the RVV.
	pages = {
		{
			titleNl = "B1 — Voorrangsweg",
			text = "B1 geeft aan dat je op een voorrangsweg rijdt. Bestuurders uit zijwegen verlenen jou voorrang. Als je afslaat, gelden ook de regels voor afslaan. Volg de verkeerslichten en de aanwijzingen van een verkeersregelaar.\n\nVoorbeeld: je rijdt rechtdoor op je bromfiets. Een auto komt uit een zijweg van rechts. De automobilist moet jou voorrang verlenen. Rijd pas door als het veilig is.",
			signCode = "B1", captionNl = "Schematische tekening. Bronlabel: RVV 1990, bijlage 1.",
		},
		{
			titleNl = "B2 — Einde voorrangsweg",
			text = "Bord B2 geeft aan dat de voorrangsweg eindigt. Bij het volgende kruispunt kijk je opnieuw welke voorrangsregels en verkeerstekens daar gelden.\n\nVoorbeeld: na B2 nader je op je bromfiets een gelijkwaardig kruispunt. Er komt een auto van rechts. Je verleent de automobilist voorrang.",
			signCode = "B2", captionNl = "De drie diagonale strepen onderscheiden dit bord van B1.",
		},
		{
			titleNl = "B6 — Voorrang verlenen",
			text = "Bij B6 verleen je voorrang aan bestuurders op de kruisende weg, zowel van links als van rechts. Je mindert vaart en stopt als dat nodig is. Als het kruispunt vrij is en je veilig kunt oversteken, mag je doorrijden.\n\nVoorbeeld: een auto komt van links. Hoewel jij voor die auto van rechts komt, verleen je de automobilist voorrang vanwege B6.",
			signCode = "B6", captionNl = "Schematische tekening. Bronlabel: RVV 1990, bijlage 1.",
		},
		{
			titleNl = "B7 — Stop en verleen voorrang",
			text = "Bij B7 kom je eerst volledig tot stilstand. Is er een stopstreep voor jou, dan stop je ervoor. Daarna verleen je voorrang aan bestuurders op de kruisende weg.\n\nVoorbeeld: je nadert op je bromfiets een leeg kruispunt. Bij B6 mag je doorrijden als het veilig is. Bij B7 moet je ook op een leeg kruispunt eerst stoppen.",
			signCode = "B7", captionNl = "Het woord STOP maakt deel uit van de tekening van het bord.",
		},
		{
			titleNl = "G11 — Verplicht fietspad",
			text = "Met een bromfiets met geel kenteken mag je niet op dit fietspad. Als er geen fiets/bromfietspad is, gebruik je de rijbaan.\n\nMet een snorfiets gelden meestal de regels voor fietsers. Je gebruikt dit verplichte fietspad, behalve als een onderbord aangeeft dat snorfietsers naar de rijbaan moeten.",
			signCode = "G11", captionNl = "RVV 1990, artikelen 2b, 5 en 6.",
		},
		{
			titleNl = "G12a — Fiets/bromfietspad",
			text = "Met je bromfiets gebruik je het fiets/bromfietspad als dat er is. Op dit pad is je maximumsnelheid 30 km/uur binnen de bebouwde kom en 40 km/uur buiten de bebouwde kom. Houd je aan een lagere limiet als die geldt.",
			signCode = "G12a", captionNl = "RVV 1990, artikelen 6, 20 en 21.",
		},
		{
			titleNl = "G13 — Onverplicht fietspad",
			text = "Met een snorfiets met verbrandingsmotor mag je dit fietspad gebruiken als je motor uit staat. Laat je de motor aan en is er geen verplicht fietspad of fiets/bromfietspad? Dan gebruik je de rijbaan.\n\nMet een elektrische snorfiets mag je dit pad ook met ingeschakelde motor gebruiken.",
			signCode = "G13", captionNl = "RVV 1990, artikel 2b en artikel 5, lid 3.",
		},
		{
			titleNl = "C2 — Eenrichtingsweg",
			text = "Zie je bord C2 aan het begin van een straat? Dan mag je die eenrichtingsweg vanaf jouw kant niet inrijden. Dat geldt ook op een bromfiets of een fiets. Kijk of een onderbord een uitzondering aangeeft.",
			signCode = "C2", captionNl = "RVV 1990, bijlage 1 en artikel 62.",
		},
		{
			titleNl = "C13 — Gesloten met werkende motor",
			text = "Dit bord sluit de weg af voor bromfietsen, snorfietsen en gehandicaptenvoertuigen met een werkende motor. Een werkende elektromotor telt ook. Op een gewone fiets mag je hier wel rijden.\n\nLoop je naast je bromfiets en neem je die aan de hand mee? Dan volg je de regels voor voetgangers.",
			signCode = "C13", captionNl = "RVV 1990, bijlage 1 en artikel 2, lid 2.",
		},
		{
			titleNl = "C15 — Gesloten voor fiets en bromfiets",
			text = "Dit bord sluit de weg af voor fietsers, bromfietsers, snorfietsers en bestuurders van gehandicaptenvoertuigen. Rijd je op een bromfiets met de motor uit? Dan geldt het verbod nog steeds.\n\nOp een gewone fiets mag je bij C13 wel doorrijden. Bij C15 mag dat niet.",
			signCode = "C15", captionNl = "RVV 1990, bijlage 1 en artikelen 2b en 62.",
		},
		{
			titleNl = "A1 — Maximumsnelheid",
			text = "Het getal op A1 geeft een maximumsnelheid aan. Met een bromfiets op de rijbaan houd je je aan de laagste limiet: die op het bord of die voor je bromfiets.\n\nStaat er 50 op het bord, dan mag je op de rijbaan maximaal 45 km/uur rijden. Staat er 30, dan geldt voor jou maximaal 30 km/uur.",
			signCode = "A1-50", captionNl = "RVV 1990, artikelen 20, 21 en 63b.",
		},
		{
			titleNl = "A2 — Einde maximumsnelheid",
			text = "Bij A2 eindigt de maximumsnelheid die op het bord staat. Kijk daarna welke limiet geldt voor je voertuig en het deel van de weg waar je rijdt.\n\nVoorbeeld: je passeert A2 met 30 op de rijbaan binnen de bebouwde kom. Geldt daar geen lagere limiet, dan mag je op je bromfiets maximaal 45 km/uur.",
			signCode = "A2-30", captionNl = "RVV 1990, bijlage 1 en artikel 20.",
		},
		{
			titleNl = "Begin Zone 30",
			text = "Bij dit bord rijd je een zone in met een maximumsnelheid van 30 km/uur. De limiet geldt in de hele zone.\n\nVoorbeeld: je rijdt de zone in en slaat bij het volgende kruispunt rechtsaf. Je bent nog in de zone. Ook zonder nieuw snelheidsbord blijft 30 km/uur gelden.",
			signCode = "A1-30-ZB", captionNl = "RVV 1990, artikel 66.",
		},
		{
			titleNl = "Einde Zone 30",
			text = "Bij dit bord verlaat je de Zone 30. De zonelimiet eindigt zodra je het bord passeert. Vanaf daar kijk je welke maximumsnelheid geldt voor je voertuig en de weg.",
			signCode = "A2-30-ZE", captionNl = "RVV 1990, bijlage 1 en artikel 66.",
		},
	},
}
