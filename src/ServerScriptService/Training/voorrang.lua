-- ModuleScript: ServerScriptService > Training > voorrang
return {
	kind = "scene",
	questions = {
		{
			id = "cyclist_right_01", titleNl = "Fietser van rechts", actorKind = "bicycle", startX = 30, laneZ = -9.5,
			prompt = "Je nadert op je bromfiets een gelijkwaardig kruispunt van twee verharde wegen. Een fietser komt van rechts en rijdt rechtdoor. Er zijn geen voorrangstekens of werkende verkeerslichten. Aan wie verleen je voorrang?",
			options = { "Ik rijd door: een bromfiets gaat vóór een fiets.", "Ik verleen de fietser van rechts voorrang.", "Ik versnel om nog vóór de fietser langs te rijden." },
			branches = { "drive", "yield", "rush" },
			correct = 2, explanationNl = "De fietser is een bestuurder die voor jou van rechts komt. Je verleent de fietser voorrang.",
		},
		{
			id = "unpaved_01", titleNl = "Van onverhard naar verhard", actorKind = "car", startX = -30, laneZ = -3.5, unpaved = true,
			prompt = "Je rijdt op een onverharde weg naar een kruispunt. Van links komt een auto op de verharde weg. Er zijn geen voorrangstekens of werkende verkeerslichten. Wat doe je?",
			options = { "Ik verleen de auto op de verharde weg voorrang.", "Ik rijd eerst, omdat de auto van links komt.", "Ik rijd eerst, omdat ik op een bromfiets rijd." },
			branches = { "yield", "drive", "rush" },
			correct = 1, explanationNl = "Bestuurders op een onverharde weg verlenen voorrang aan bestuurders op een verharde weg, ook als die van links komen.",
		},
		{
			id = "tram_demo_01", titleNl = "Tram van links", actorKind = "tram", startX = -30, laneZ = -6.5,
			prompt = "Je nadert een kruispunt zonder voorrangsregeling, werkende verkeerslichten of verkeersregelaar. Een tram komt van links. Wat doe je?",
			options = { "Ik rijd door, omdat de tram van links komt.", "Ik versnel om nog vóór de tram langs te rijden.", "Ik verleen de tram voorrang." },
			branches = { "drive", "rush", "yield" },
			correct = 3, explanationNl = "Bij deze ongeregelde kruising verleen je de tram voorrang, ook als de tram van links komt. Dit betekent niet dat een tram in iedere situatie voorrang heeft.",
		},
	},
}
