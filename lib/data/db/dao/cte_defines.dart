import 'dao_util.dart';

String childCountsWithRange(int? beginYear, int? endYear) =>
'''
sire_child_counts AS (
  SELECT
    father_id AS sire_id,
    COUNT(sex) AS child_count,
    COUNT(rating) AS own_count
  FROM horses
  ${whereStr([
    'sex IS NOT NULL',
    yearRange('birth_year', beginYear, endYear),
  ])}
  GROUP BY father_id
),
mare_child_counts AS (
  SELECT
    mother_id AS mare_id,
    COUNT(sex) AS child_count,
    COUNT(rating) AS own_count
  FROM horses
  ${whereStr([
    'sex IS NOT NULL',
    yearRange('birth_year', beginYear, endYear),
  ])}  
  GROUP BY mother_id        
),
sire_mare_counts AS (
  SELECT
    m.father_id AS sire_id,
    COUNT(m.id) AS mare_count
  FROM mares m
  LEFT JOIN mare_child_counts mc ON mc.mare_id = m.id
  WHERE COALESCE(mc.child_count, 0) > 0
  GROUP BY father_id
)
''';

String get childCountsTable => childCountsWithRange(null, null);

const stallionsTable =
'''
stallions AS (
  SELECT
    s.id,
    s.name,
    s.father_id,
    s.is_historical,
    s.is_founder,
    s.lineage_status,
    COALESCE(sc.child_count, 0) AS child_count,
    COALESCE(sc.own_count,   0) AS own_count,
    COALESCE(sm.mare_count,  0) AS mare_count
  FROM sires s
  LEFT JOIN sire_child_counts sc ON sc.sire_id = s.id
  LEFT JOIN sire_mare_counts sm ON sm.sire_id = s.id
)
''';

const bloodmaresTable =
'''
bloodmares AS (
  SELECT
    m.id,
    m.name,
    m.father_id,
    m.mother_id,
    m.is_historical,
    m.is_founder,
    m.is_grade_winner,
    m.farm,
    m.breeding_policy,
    COALESCE(mc.child_count, 0) AS child_count,
    COALESCE(mc.own_count,   0) AS own_count
  FROM mares m
  LEFT JOIN mare_child_counts mc ON mc.mare_id = m.id
)
''';

const sireLineTable =
'''
major_line AS (
  SELECT
    id   AS founder_id,
    name AS lineage_name,
    id   AS sire_id
  FROM sires
  WHERE lineage_status = 2

  UNION ALL

  SELECT
    l.founder_id,
    l.lineage_name,
    s.id AS sire_id
  FROM sires s
  INNER JOIN major_line l ON s.father_id = l.sire_id
  WHERE s.lineage_status < 2
),
minor_line AS (
  SELECT
    id   AS founder_id,
    name AS lineage_name,
    id   AS sire_id
  FROM sires
  WHERE lineage_status >= 1

  UNION ALL

  SELECT
    l.founder_id,
    l.lineage_name,
    s.id AS sire_id
  FROM sires s
  INNER JOIN minor_line l ON s.father_id = l.sire_id
  WHERE s.lineage_status < 1
)
''';

const familiesTable =
'''
families AS (
  SELECT
    id    AS founder_id,
    name  AS family_name,
    id    AS mare_id
  FROM mares
  WHERE is_founder = TRUE

  UNION ALL

  SELECT
    f.founder_id,
    f.family_name,
    h.id AS mare_id
  FROM mares h
  INNER JOIN families f ON h.mother_id = f.mare_id
)
''';