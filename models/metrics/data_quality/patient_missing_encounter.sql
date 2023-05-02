{{ config(
    meta = {
      "description": "Proportion of patients that do not have an encounter",
      "short_description": "Patients missing encounters",
      "primary_resource": "Patient",
      "primary_fields": ['active'],
      "secondary_resources": ["Encounter"],
      "calculation": "PROPORTION",
      "category": "Data completeness",
      "dimension_a": "active",
      "dimension_a_description": "The patient active status  (true | false)",
    }
) -}}

{%- set metric_sql -%}
    SELECT
      P.id,
      {{- metric_common_dimensions(table_alias='P', exclude_col='metric_date') }}
      CAST(NULL AS DATE) AS metric_date,
      CAST( {{ get_column_or_default('P.active') }} AS STRING) AS active,
      SIGN(SUM(CASE WHEN E.id IS NULL THEN 0 ELSE 1 END)) AS patient_missing_encounter
    FROM {{ ref('Patient') }} AS P
    LEFT JOIN {{ ref('Encounter') }} AS E
      ON E.subject.patientid=P.id
      AND UPPER(E.status) NOT IN ('ENTERED-IN-ERROR')
      AND UPPER(class.code) IN ('IMP', 'ACUTE', 'NONAC', 'SS', 'OBSENC', 'EMER', 'IMPPS', 'IMPRE','AMB')
      GROUP BY 1, 2, 3, 4, 5, 6, 7
{%- endset -%}

{{ calculate_metric(
    metric_sql,
    numerator = 'SUM(patient_missing_encounter)',
    denominator = 'COUNT(id)'
) }}