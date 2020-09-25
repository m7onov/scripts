with rel_info as (
  select c.gp_segment_id,
         pg_relation_filepath(c.oid) filepath,
         gp_toolkit.__gp_aocsseg(c.oid) i
    from gp_dist_random('pg_class') c
   where c.oid='staging.public__system_variable'::regclass
)
select hostname,
       datadir || '/' || ri.filepath || '.' || (i).physical_segno::text,
       (i).column_num,
       (i).tupcount
  from rel_info ri
 inner join gp_segment_configuration sc
         on role='p' and
            sc.content=ri.gp_segment_id
 order by 1,2;
