-- etcd join date
-- \set join_date '2018-12-11'
-- Cilium join date
\set join_date '2021-10-13'
-- Before join
select count(distinct e.actor_id) as "Contributors before join" from gha_events e left join gha_actors_affiliations aa on aa.actor_id = e.actor_id and aa.dt_from <= e.created_at and aa.dt_to > e.created_at where e.type in ('PushEvent', 'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewEvent', 'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent') and e.created_at < :'join_date';
select count(distinct e.actor_id) as "Affiliated contributors before join" from gha_events e left join gha_actors_affiliations aa on aa.actor_id = e.actor_id and aa.dt_from <= e.created_at and aa.dt_to > e.created_at where e.type in ('PushEvent', 'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewEvent', 'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent') and e.created_at < :'join_date' and aa.company_name is not null and lower(aa.company_name) != 'independent';
select count(distinct e.actor_id) as "Unaffiliated contributors before join" from gha_events e left join gha_actors_affiliations aa on aa.actor_id = e.actor_id and aa.dt_from <= e.created_at and aa.dt_to > e.created_at where e.type in ('PushEvent', 'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewEvent', 'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent') and e.created_at < :'join_date' and aa.company_name is null;
select count(distinct e.actor_id) as "Individual contributors before join" from gha_events e left join gha_actors_affiliations aa on aa.actor_id = e.actor_id and aa.dt_from <= e.created_at and aa.dt_to > e.created_at where e.type in ('PushEvent', 'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewEvent', 'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent') and e.created_at < :'join_date' and lower(aa.company_name) = 'independent';
select count(distinct aa.company_name) as "Companies before join" from gha_events e left join gha_actors_affiliations aa on aa.actor_id = e.actor_id and aa.dt_from <= e.created_at and aa.dt_to > e.created_at where e.type in ('PushEvent', 'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewEvent', 'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent') and e.created_at < :'join_date' and aa.company_name is not null and lower(aa.company_name) != 'independent';
-- After join
select count(distinct e.actor_id) as "Contributors after join" from gha_events e left join gha_actors_affiliations aa on aa.actor_id = e.actor_id and aa.dt_from <= e.created_at and aa.dt_to > e.created_at where e.type in ('PushEvent', 'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewEvent', 'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent') and e.created_at >= :'join_date';
select count(distinct e.actor_id) as "Affiliated contributors after join" from gha_events e left join gha_actors_affiliations aa on aa.actor_id = e.actor_id and aa.dt_from <= e.created_at and aa.dt_to > e.created_at where e.type in ('PushEvent', 'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewEvent', 'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent') and e.created_at >= :'join_date' and aa.company_name is not null and lower(aa.company_name) != 'independent';
select count(distinct e.actor_id) as "Unaffiliated contributors after join" from gha_events e left join gha_actors_affiliations aa on aa.actor_id = e.actor_id and aa.dt_from <= e.created_at and aa.dt_to > e.created_at where e.type in ('PushEvent', 'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewEvent', 'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent') and e.created_at >= :'join_date' and aa.company_name is null;
select count(distinct e.actor_id) as "Individual contributors after join" from gha_events e left join gha_actors_affiliations aa on aa.actor_id = e.actor_id and aa.dt_from <= e.created_at and aa.dt_to > e.created_at where e.type in ('PushEvent', 'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewEvent', 'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent') and e.created_at >= :'join_date' and lower(aa.company_name) = 'independent';
select count(distinct aa.company_name) as "Companies after join" from gha_events e left join gha_actors_affiliations aa on aa.actor_id = e.actor_id and aa.dt_from <= e.created_at and aa.dt_to > e.created_at where e.type in ('PushEvent', 'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewEvent', 'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent') and e.created_at >= :'join_date' and aa.company_name is not null and lower(aa.company_name) != 'independent';
-- All time
select count(distinct e.actor_id) as "All time contributors" from gha_events e left join gha_actors_affiliations aa on aa.actor_id = e.actor_id and aa.dt_from <= e.created_at and aa.dt_to > e.created_at where e.type in ('PushEvent', 'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewEvent', 'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent');
select count(distinct e.actor_id) as "All time affiliated contributors" from gha_events e left join gha_actors_affiliations aa on aa.actor_id = e.actor_id and aa.dt_from <= e.created_at and aa.dt_to > e.created_at where e.type in ('PushEvent', 'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewEvent', 'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent') and aa.company_name is not null and lower(aa.company_name) != 'independent';
select count(distinct e.actor_id) as "All time unaffiliated contributors" from gha_events e left join gha_actors_affiliations aa on aa.actor_id = e.actor_id and aa.dt_from <= e.created_at and aa.dt_to > e.created_at where e.type in ('PushEvent', 'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewEvent', 'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent') and aa.company_name is null;
select count(distinct e.actor_id) as "All time individual contributors" from gha_events e left join gha_actors_affiliations aa on aa.actor_id = e.actor_id and aa.dt_from <= e.created_at and aa.dt_to > e.created_at where e.type in ('PushEvent', 'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewEvent', 'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent') and lower(aa.company_name) = 'independent';
select count(distinct aa.company_name) as "All time companies" from gha_events e left join gha_actors_affiliations aa on aa.actor_id = e.actor_id and aa.dt_from <= e.created_at and aa.dt_to > e.created_at where e.type in ('PushEvent', 'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewEvent', 'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent') and aa.company_name is not null and lower(aa.company_name) != 'independent';
-- New after join
select count(distinct e.actor_id) as "New contributors after join" from gha_events e left join gha_actors_affiliations aa on aa.actor_id = e.actor_id and aa.dt_from <= e.created_at and aa.dt_to > e.created_at where e.type in ('PushEvent', 'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewEvent', 'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent') and e.created_at >= :'join_date' and e.actor_id not in (select e.actor_id from gha_events e left join gha_actors_affiliations aa on aa.actor_id = e.actor_id and aa.dt_from <= e.created_at and aa.dt_to > e.created_at where e.type in ('PushEvent', 'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewEvent', 'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent') and e.created_at < :'join_date');
select count(distinct e.actor_id) as "New affiliated contributors after join" from gha_events e left join gha_actors_affiliations aa on aa.actor_id = e.actor_id and aa.dt_from <= e.created_at and aa.dt_to > e.created_at where e.type in ('PushEvent', 'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewEvent', 'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent') and e.created_at >= :'join_date' and aa.company_name is not null and lower(aa.company_name) != 'independent' and e.actor_id not in (select e.actor_id from gha_events e left join gha_actors_affiliations aa on aa.actor_id = e.actor_id and aa.dt_from <= e.created_at and aa.dt_to > e.created_at where e.type in ('PushEvent', 'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewEvent', 'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent') and e.created_at < :'join_date');
select count(distinct e.actor_id) as "New unaffiliated contributors after join" from gha_events e left join gha_actors_affiliations aa on aa.actor_id = e.actor_id and aa.dt_from <= e.created_at and aa.dt_to > e.created_at where e.type in ('PushEvent', 'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewEvent', 'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent') and e.created_at >= :'join_date' and aa.company_name is null and e.actor_id not in (select e.actor_id from gha_events e left join gha_actors_affiliations aa on aa.actor_id = e.actor_id and aa.dt_from <= e.created_at and aa.dt_to > e.created_at where e.type in ('PushEvent', 'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewEvent', 'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent') and e.created_at < :'join_date');
select count(distinct e.actor_id) as "New individual contributors after join" from gha_events e left join gha_actors_affiliations aa on aa.actor_id = e.actor_id and aa.dt_from <= e.created_at and aa.dt_to > e.created_at where e.type in ('PushEvent', 'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewEvent', 'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent') and e.created_at >= :'join_date' and lower(aa.company_name) = 'independent' and e.actor_id not in (select e.actor_id from gha_events e left join gha_actors_affiliations aa on aa.actor_id = e.actor_id and aa.dt_from <= e.created_at and aa.dt_to > e.created_at where e.type in ('PushEvent', 'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewEvent', 'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent') and e.created_at < :'join_date');
select count(distinct aa.company_name) as "New companies after join" from gha_events e left join gha_actors_affiliations aa on aa.actor_id = e.actor_id and aa.dt_from <= e.created_at and aa.dt_to > e.created_at where e.type in ('PushEvent', 'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewEvent', 'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent') and e.created_at >= :'join_date' and aa.company_name is not null and lower(aa.company_name) != 'independent' and e.actor_id not in (select e.actor_id from gha_events e left join gha_actors_affiliations aa on aa.actor_id = e.actor_id and aa.dt_from <= e.created_at and aa.dt_to > e.created_at where e.type in ('PushEvent', 'PullRequestEvent', 'IssuesEvent', 'PullRequestReviewEvent', 'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent') and e.created_at < :'join_date');