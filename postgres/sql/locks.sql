select waiter.pid               as waiter_pid,
       waiter_activity.usename  as waiter_user,
       blocker.pid              as blocker_pid,
       blocker_activity.usename as blocker_user,
       waiter_activity.query    as waiter_statement,
       blocker_activity.query   as blocker_statement
  from pg_catalog.pg_locks waiter
 inner join pg_catalog.pg_locks blocker
         on blocker.locktype = waiter.locktype and
            blocker.pid != waiter.pid and
            blocker.database is not distinct from waiter.database and
            blocker.relation is not distinct from waiter.relation and
            blocker.page is not distinct from waiter.page and
            blocker.tuple is not distinct from waiter.tuple and
            blocker.virtualxid is not distinct from waiter.virtualxid and
            blocker.transactionid is not distinct from waiter.transactionid and
            blocker.classid is not distinct from waiter.classid and
            blocker.objid is not distinct from waiter.objid and
            blocker.objsubid is not distinct from waiter.objsubid
 inner join pg_catalog.pg_stat_activity waiter_activity
         on waiter_activity.pid = waiter.pid
 inner join pg_catalog.pg_stat_activity blocker_activity
         on blocker_activity.pid = blocker.pid
 where not waiter.granted;

