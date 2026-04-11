const horseIdentityColumns =
'''
h.birth_year,
h.name,
h.sex,
f.name AS father_name,
b.name AS mother_name
''';

const horseStatusColumns =
'''
h.growth,
h.surface,
h.distance,
h.rating
''';

const foalRatingColumns =
'''
h.rating01,
h.rating02,
h.rating03,
h.rating04,
h.rating05
''';

const horseExtraColumns =
'''
h.mating_rank,
h.explosion_power,
h.retire_year,
h.is_historical,
h.region
''';

const breedingExistsExpr =
'''
(
  EXISTS (
    SELECT 1
    FROM stallions s
    WHERE s.name = h.name AND s.child_count > 0
  ) OR
  EXISTS (
    SELECT 1
    FROM bloodmares m
    WHERE m.name = h.name AND m.child_count > 0
  )
) AS breeding
''';

const lineageCountJoins =
'''
LEFT JOIN sire_child_counts sc
  ON sc.sire_id = l.id
LEFT JOIN sire_mare_counts sm
  ON sm.sire_id = l.id
LEFT JOIN sire_mare_counts dcm
  ON dcm.sire_id = l.founder_id
''';

const lineageScale =
'''
COUNT(sc.child_count)  AS active_sire_count,
SUM(COALESCE(sc.child_count, 0))  AS descendant_count,
SUM(COALESCE(sc.own_count,   0))  AS own_descendant_count,
SUM(COALESCE(sm.mare_count,  0))  AS mare_count,
COALESCE(dcm.mare_count, 0) AS direct_mare_count
''';
