extends SceneTree

var _failures: int = 0


@override
func _initialize() -> void:
	_test_ccl_round_trip()
	_test_forward_compatible_save()
	_test_catalog_integrity()
	_test_boon_integrity()
	if _failures == 0:
		print("PALIMPSEST TESTS: 4 suites passed")
		quit(0)
	else:
		push_error("PALIMPSEST TESTS: %d failure(s)" % _failures)
		quit(1)


@private
func _test_ccl_round_trip() -> void:
	var original := ArchiveSaveManager.create_default_profile()
	original.expeditions = 7
	original.archive_fragments = 31
	original.discovered_records.append("child_map")
	original.endings_seen.append("mercy")
	original.wick_rank = 3
	var decoded := PalimpsestSaveData.deserialize_binary(original.serialize_binary())
	_expect(decoded.expeditions == 7, "CCL expeditions round-trip")
	_expect(decoded.archive_fragments == 31, "CCL fragment round-trip")
	_expect(decoded.discovered_records == ["child_map"], "CCL string-array round-trip")
	_expect(decoded.endings_seen == ["mercy"], "CCL appended ending field round-trip")
	_expect(decoded.wick_rank == 3, "CCL appended rank field round-trip")


@private
func _test_forward_compatible_save() -> void:
	var original := ArchiveSaveManager.create_default_profile()
	original.total_echoes = 19
	var bytes := original.serialize_binary()
	var old_version_bytes := bytes.slice(0, maxi(1, bytes.size() - 18))
	var decoded := PalimpsestSaveData.deserialize_binary(old_version_bytes)
	_expect(is_instance_valid(decoded), "Truncated old save remains readable")
	_expect(decoded.total_echoes == 19, "Early fields survive appended-field truncation")


@private
func _test_catalog_integrity() -> void:
	var records := LoreCatalog.all_records()
	_expect(records.size() == 24, "Lore catalogue contains 24 records")
	var ids: Array[String] = []
	for record: LoreRecord in records:
		_expect(not record.record_id.is_empty(), "Lore record id is non-empty")
		_expect(record.record_id not in ids, "Lore record id is unique: %s" % record.record_id)
		ids.append(record.record_id)
	_expect(LoreCatalog.available_records(0).size() >= 7, "First expedition has enough unique echoes")


@private
func _test_boon_integrity() -> void:
	var ids := BoonCatalog.base_ids()
	_expect(ids.size() >= 8, "Base boon pool has build variety")
	for boon_id: StringName in ids:
		var info := BoonCatalog.definition(boon_id)
		_expect(info.boon_id == boon_id, "Boon lookup preserves id: %s" % boon_id)
		_expect(not info.title.is_empty() and not info.description.is_empty(), "Boon copy is complete: %s" % boon_id)


@private
func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("TEST FAILURE: %s" % message)
