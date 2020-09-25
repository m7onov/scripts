with w_t as (
  select 1 as id, 'mcv' as name union all
  select 2 as id, 'hist' as name union all
  select 3 as id, 'corr' as name union all
  select 4 as id, 'mcelem' as name union all
  select 5 as id, 'dechist' as name union all
  select 6 as id, 'rlh' as name union all
  select 7 as id, 'bh' as name union all
  -- HyperLogLog in greenplum
  select 99 as id, 'hll' as name
),
w_s as (
  select s.starelid, s.staattnum, 1 as f, s.stakind1 as stakind, s.staop1 as staop, s.stanumbers1 as stanumbers, s.stavalues1 as stavalues from pg_statistic s union all
  select s.starelid, s.staattnum, 2 as f, s.stakind2 as stakind, s.staop2 as staop, s.stanumbers2 as stanumbers, s.stavalues2 as stavalues from pg_statistic s union all
  select s.starelid, s.staattnum, 3 as f, s.stakind3 as stakind, s.staop3 as staop, s.stanumbers3 as stanumbers, s.stavalues3 as stavalues from pg_statistic s union all
  select s.starelid, s.staattnum, 4 as f, s.stakind4 as stakind, s.staop4 as staop, s.stanumbers4 as stanumbers, s.stavalues4 as stavalues from pg_statistic s union all
  select s.starelid, s.staattnum, 5 as f, s.stakind5 as stakind, s.staop5 as staop, s.stanumbers5 as stanumbers, s.stavalues5 as stavalues from pg_statistic s
)
select n.nspname,
       c.relname,
       a.attname,
       s.stainherit,
       s.stanullfrac,
       s.stawidth,
       s.stadistinct,
       w_t.name as stakind,
       w_s.*
  from pg_statistic s
  left join pg_attribute a
         on a.attrelid = s.starelid and
            a.attnum = s.staattnum
  left join pg_class c
         on c.oid = s.starelid
  left join pg_namespace n
         on n.oid = c.relnamespace
  left join w_s
         on w_s.starelid = s.starelid and
            w_s.staattnum = s.staattnum and
            nullif(w_s.stakind, 0) is not null
  left join w_t
         on w_t.id = w_s.stakind
 where n.nspname not in ('pg_catalog', 'information_schema')
   and n.nspname like '%'
   and c.relname like '%'
 order by 1, 2, 3
 limit 1000;
