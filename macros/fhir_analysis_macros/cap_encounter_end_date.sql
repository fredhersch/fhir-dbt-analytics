-- Copyright 2023 Google LLC
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

{%- macro cap_encounter_end_date(
  period_start='period_start',
  period_end='period_end',
  encounter_class='encounter_class',
  length_of_stay_cap=None
) -%}
{%- if length_of_stay_cap == None -%}
{%- set length_of_stay_cap = var('length_of_stay_cap') -%}
{%- endif -%}
LEAST(
  IFNULL({{period_end}}, CURRENT_DATE()),
  {{ fhir_dbt_utils.date_add_days(period_start, length_of_stay_cap) }},
  IF({{encounter_class}} = 'AMB', {{period_start}}, CURRENT_DATE())
)
{%- endmacro -%}