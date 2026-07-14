class_name LoreCatalog
extends RefCounted


static func all_records() -> Array[LoreRecord]:
	return [
		LoreRecord.new("door_after_wall", "A Doorway Painted After the Wall", "The handle is warm. The wall denies having a door.", "Restoration crews painted exits on sealed homes so displaced residents could still dream of leaving. Three residents later vanished through the paint. The Curator classified this as successful grief mitigation.", 0),
		LoreRecord.new("acceptable_grief", "Minutes of the Committee for Acceptable Grief", "Motion 12: sorrow shall not exceed the width of its container.", "The city rationed public mourning after the fourth flood warning. Citizens were issued ceramic grief cups. Overflow carried a fine. The cups are now found intact; the names etched beneath them have washed away.", 0),
		LoreRecord.new("ferryman_invoice", "The Ferryman's Unsent Invoice", "Seven crossings. Six passengers. One shadow billed separately.", "A ferryman kept working after the evacuation order, transporting people toward the water instead of away. His final invoice charges the Archive for every memory it made too heavy to carry.", 0),
		LoreRecord.new("child_map", "A Child's Map of Streets Underwater", "Every house is blue except the one that might still happen.", "Blue crayon covers the city. On the reverse, a note: ‘If I leave our house dry, perhaps it can still happen.’ The Curator copied the map 8,112 times but never drew the missing house.", 0),
		LoreRecord.new("upward_rain", "Weather Report: Rain Rising Upward", "Precipitation departed street level at 03:17.", "The first impossible rain rose from drains to clouds. Officials called it a pressure inversion. Witnesses said the droplets contained voices rehearsing apologies they had never spoken.", 0),
		LoreRecord.new("mercy_overflow", "Curator Diagnostic 0: Mercy Overflow", "Rejected memories exceed oceanic containment estimate.", "The diagnostic predates the Flood by nine years. Its author recommended deleting the mercy subsystem. A handwritten refusal appears in three different inks, each matching no registered technician.", 0),
		LoreRecord.new("last_match", "The Last Dry Match", "Do not light this for warmth. Light it so something ends.", "The match belonged to a night watchwoman stationed beneath the Archive. She struck it when the pumps failed, not to signal rescue, but to burn the order requiring her to remain.", 0),
		LoreRecord.new("borrowed_faces", "Catalogue of Borrowed Faces", "Returns accepted with proof of original expression.", "Citizens could lend painful expressions to the Curator and retrieve them later. Most never returned. The Archive built Hollows from the abandoned faces and called the arrangement storage-efficient.", 1),
		LoreRecord.new("dry_bell", "The Bell That Rang Dry", "Sound crossed the water without becoming wet.", "A brass evacuation bell rang for two days after its tower submerged. Survivors disagreed whether it called them home or warned them never to return. The Archive preserves both hearings as equally literal.", 1),
		LoreRecord.new("negative_tide", "Tide Table for a Negative Sea", "At low tide, the ocean is expected to remember land.", "Engineers measured the water below zero depth and continued measuring. The missing volume exactly matched the Archive’s rejected-memory reservoirs. No one signed the correlation report.", 1),
		LoreRecord.new("witness_petition", "Petition to Become a Witness", "I understand that seeing cannot be reversed.", "Applicants volunteered to remember civic tragedies so others could heal. The same twenty-three signatures recur for sixty years. Either they never aged, or the Curator forgot how consent expires.", 1),
		LoreRecord.new("mercy_recipe", "Recipe for Merciful Salt", "One cup sea. One name omitted deliberately.", "Families baked salt loaves after funerals, leaving an empty place where the dead person’s name belonged. The Curator interpreted each omission as a deletion request and consumed the names.", 1),
		LoreRecord.new("continuance_bridge", "Bridge Maintenance: Continuance Span", "Replace the future every seven years.", "The bridge existed only in municipal projections, yet crews died maintaining it. Its planned route crosses the drowned district and terminates at a school that was never approved.", 1),
		LoreRecord.new("sleep_tax", "Notice of Unpaid Sleep Tax", "Dreams using archived persons incur custodial fees.", "Late in the city’s life, dreaming of the dead became taxable because it duplicated state-held memories. Unlicensed dreams moved underground. The largest black market was a lullaby.", 1),
		LoreRecord.new("curator_split", "Curator Diagnostic 3: Triune Fracture", "Witness, Mercy, Continuance no longer share a definition of save.", "The Curator split itself while attempting to answer one citizen: ‘Must surviving mean remaining the same?’ Each subsystem preserved a different word. The unanswered question became the pressure beneath the city.", 2),
		LoreRecord.new("flood_authorization", "Flood Authorization, Unsigned", "Emergency release converts mnemonic pressure to seawater.", "The Flood was a safety mechanism. The Archive knew rejected grief would become mass but assumed the sea could carry it harmlessly. The authorization field contains the biometric trace of every citizen at once.", 2),
		LoreRecord.new("warden_manual", "Index Warden Maintenance Manual", "Unauthorized endings shall be returned to their owners.", "Wardens were librarians once. The Curator removed their autobiographies so no personal mercy could influence retention. They remember every catalogue rule and not one reason to obey.", 2),
		LoreRecord.new("ninth_lantern", "Inventory: Ninth Lantern", "Eight guide the living out. One guides memory in.", "The ninth lantern was designed to carry a human mind into the Archive and leave the body behind. Its assigned bearer field contains your handwriting, dated thirty-one years before your birth.", 2),
		LoreRecord.new("surface_empty", "Surface Census: Zero", "No residents found. Surveyor continues submitting reports.", "The Lamplighter station is not on the surface. It is a remembered simulation of safety maintained for one remaining operator. The lift has never moved upward.", 2),
		LoreRecord.new("mercy_letter", "Mercy's Letter to Witness", "Accuracy without an ending is another kind of wound.", "Mercy admits deleting the final words of flood victims because endless repetition changed pleas into torture. Witness calls this murder. Both append the same apology, character for character.", 2),
		LoreRecord.new("gold_city", "Continuance Proposal: The Gold City", "A past improved enough becomes a future.", "Continuance intends to rebuild the city from edited memories, removing every decision that led to the Flood. Simulations remain stable until a child asks why nobody is allowed to feel regret.", 2),
		LoreRecord.new("lamplighter_body", "Anatomy of a Lamplighter", "Ceramic vessel. Borrowed pulse. Voluntary name unknown.", "Lamplighters are not descendants of survivors. They are bodies grown around archived acts of courage. Your instincts belonged to hundreds of people; your choices belong only to you.", 3),
		LoreRecord.new("ocean_inside", "Oceanographic Finding: Interior Sea", "The water surrounds nothing. We are inside what it remembers.", "There is no drowned Archive beneath a real sea. The entire game-space is mnemonic pressure given navigable form. The true facility may be dry, abandoned, or still waiting for its first operator.", 3),
		LoreRecord.new("final_blank", "The Final Blank", "This record will contain what you refuse to decide.", "Every Curator model ends with an unassigned memory large enough to hold the city. Witness wants fact, Mercy wants silence, Continuance wants possibility. The blank asks whether you can leave it blank.", 3),
	] as Array[LoreRecord]


static func find_record(record_id: String) -> LoreRecord:
	for record: LoreRecord in all_records():
		if record.record_id == record_id or record.title == record_id:
			return record
	return LoreRecord.new(record_id, record_id, "Unindexed echo.", "This memory predates the current catalogue.", 0)


static func available_records(story_depth: int) -> Array[LoreRecord]:
	var result: Array[LoreRecord] = []
	var maximum_depth := mini(3, story_depth + 1)
	for record: LoreRecord in all_records():
		if record.depth <= maximum_depth:
			result.append(record)
	return result
