# SIMP Grafana Dashboards

## Purpose

This repository serves as a home for pre-built [Grafana][Grafana] dashboards meant to work
with the [SIMP ELG][SIMP ELG] stack.

Many, if not most, of these dashboards will work with any [Grafana][Grafana] setup but
they have been specifically tested against the [SIMP][SIMP] stack and will be included
as they mature over time.

Some of the dashboards require fields to be extracted from logs.  We use [Logstash][Logstash].
Our filters can be found in our [Logstash module repository][Logstash].

We enabled json dashboards with the SIMP grafana module.  If you install these without SIMP,
you will need to manually enable json dashboards.

## Bugs

If you find any bugs, please enter a ticket in the [SIMP Ticketing System][SIMP JIRA].

## Contributing

Patches and feature requests are most welcome!

Please see the [Contribution Guide][SIMP Contrib] for the guidelines on
contributions.

Feature requests should be made via the [SIMP Ticketing System][SIMP JIRA].

[SIMP]: https://simp-project.com
[Grafana]: http://grafana.org/
[SIMP ELG]: http://simp.readthedocs.io/en/5.2.0-0/user_guide/HOWTO/Central_Log_Collection/Logstash.html
[SIMP Contrib]: https://github.com/NationalSecurityAgency/SIMP/blob/master/CONTRIBUTING.md
[SIMP JIRA]: https://simp-project.atlassian.net
[Logstash]: https://github.com/simp/pupmod-simp-simp_logstash
