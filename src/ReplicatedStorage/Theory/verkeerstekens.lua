-- ModuleScript: ReplicatedStorage > Theory > verkeerstekens
return {
	topicId = "verkeerstekens",
	titleNl = "Verkeerstekens",
	sourceName = "RVV 1990 — bijlage 1",
	sourceUrl = "https://wetten.overheid.nl/BWBR0004825/#Bijlage1",
	article = "Bijlage 1, B1/B2/B6/B7 en artikelen 15, 18, 62–64, 79, 84",
	reviewStatus = "reviewed",
	images = {},
	questionIds = { "sign_b6_01", "sign_b1_01", "sign_b7_01", "sign_b2_01" },
	sceneIds = {},
	-- The owner's first four sign explanations, edited and checked against the RVV.
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
	},
}
