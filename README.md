<details open="open">
  <summary>Table of contents</summary>

  - [Overview](#overview)
  - [How it works](#how-it-works)
  - [Deploying univer***REMOVED***l connector](#deploying-univer***REMOVED***l-connector)
  - [Monitoring univer***REMOVED***l connector  connections](#monitoring-uc-connections)
  - [Policies](#policies)
  - [Known limitations](#known-limitations)
  - [FAQs](#faqs)
  - [Developing plug-ins](#developing-plug-ins)
  - [Contributing](#contributing)
  - [Contact us](#contact-us)
  - [Licensing](#licensing)

</details>

## Overview

The Guardium univer***REMOVED***l connector enables Guardium Data Protection and Guardium Insights to get data from potentially any data source's native activity logs without using S-TAPs, that includes, among many others: information, DDLs and DMLs, error of varying sub-types, encrypted, administrative, etc. The Guardium Univer***REMOVED***l Connector includes support for MongoDB, MySQL, and Amazon S3, requiring minimal configuration. Users can easily develop plug-ins for other data sources, and install them in Guardium.

**Note:**
MongoDB, MySQL, and Amazon S3 are presented as an example of the three pre-defined, internal (meaning that they're "built-in" or pre-installed in UC -- there's no need to manually upload any .zips to execute them and no pre-requisites are required, as opposed to user made packages or other supported plug-ins which are "external"/need to be manually uploaded onto the gmachine or GI), in-house supported packages, that require minimal configs on the client end: the customer needs to simply use a ready made template for plugging in values for the input and filter sections of their respective configuration files, or expand these sections by using online pre-installed LS plug-ins or write their own ruby code parser as a pre-processing stage prior to executing the filter/input plug-ins.

Figure 1. Guardium univer***REMOVED***l connector architecture

![Univer***REMOVED***l Connector](/docs/images/guc.jpg)

<sub> Data flow from input plugin to guardium sniffer </sub>

The Guardium univer***REMOVED***l connector supports many platforms and connectivity options. It supports pull and push modes, multi-protocols, on-premises, and cloud platforms. For the data sources with pre-defined plug-ins, you configure Guardium to accept audit logs from the data source.

For data sources that do not have pre-defined plug-ins, you can customize the filtering and parsing components of audit trails and log formats. The open architecture enables reuse of prebuilt filters and parsers, and creation of shared library for the Guardium community.

The Guardium univer***REMOVED***l connector identifies and parses the received events, and converts them to a standard Guardium format. The output of the Guardium univer***REMOVED***l connector is forwarded to the Guardium sniffer on the collector, for policy and auditing enforcements. The Guardium policy, as usual, determines whether the activities are legitimate or not, when to alert, and the auditing level per activity.

The Guardium univer***REMOVED***l connector scales by adding Guardium collectors. It provides a load-balancing and fail-over mechanisms among a set of Guardium collectors. In it of itself, it might implicate distribution of the whole set of events to each of the Guardium collectors in the set, causing duplications and redundant event processing. To bypass this fallback default behavior, these mechanisms are to be configured as part of the input scope of the installed connector's configuration file.

**Note:**
See GCP's Pub/Sub input plug-in [load-balancing configuration](https://github.com/IBM/univer***REMOVED***l-connectors/tree/main/input-plugin/logstash-input-google-pubsub#note-2) as an example.

Connections to databases that are configured with the Guardium univer***REMOVED***l connector are handled the ***REMOVED***me as all other datasources in Guardium. You can apply policies, view reports, monitor connections, for example.

## How it works

The Univer***REMOVED***l Connector under-the-hood is a Logstash pipeline comprising of a series of three plug-ins:

1. Input plug-in. This plug-in ingests events. Depending on the type of plug-in, there are settings to either pull events from APIs or receive a push of events.

2. Filter plug-in. This plug-in filters events. The filter plug-in parses, filters, and modifies event logs into in a normalized format. 

3. Output plug-in. This plug-in takes the event logs in a normalized format and sends it to IBM Guardium (either Guardium Data Protection or Guardium Insights). 

![Univer***REMOVED***l Connector - Logstash pipeline](/docs/images/uc_overview.png)

Univer***REMOVED***l Connector plug-ins are packaged and deployed in a Docker container environment.

### Further how-tos (?)
There are a couple of flavors aimed at enabling audit log forwarding into Guardium for various Data Sources, comprised of either a cloud or on-premise data lake platform, of a Data Base type that is supported by the Guardium sniffer (should attach here a link to the supported dbs):

  1. The three pre-installed plug-in packages (mongo, mysql and s3) that require minimal configurations on the client's end: plugging in suited values in their respective template configuration files in the input and filter sections is sufficient OR adding a ruby code sub-section to the filter sections in case a more complex parsing method is neces***REMOVED***ry as a pre-processing stage to be executed prior to the respective filter plug-in.
  2. For not yet supported Data Sources, you can either upload an external filter plug-in or develop your own and add it to our plug-ins repository, with the option to clone and modify the existing plug-ins as a template for your convenience (either in Ruby or Java)


**Note:**
It's optional to add an input plug-in to the repository in case the existing ones are insufficient for your needs, although it's recommended to use one of the existing or preinstalled input plug-ins and modify their config files' input section accordingly


**Note:**
The Output plug-in is presented here as an under-the-hood internal component of the UC pipeline and is not to be accessed or modified by the user.


[Technical demo](https://youtu.be/LAYhVoYMb28)

## Deploying Univer***REMOVED***l Connector

In Guardium Data Protection, the overall workflow for deploying the univer***REMOVED***l connector is as follows:

1. Uploading and installing a plugin

2. Configuring native auditing on the data source

3. Sending native audit logs to the univer***REMOVED***l connector, using either a push or pull workflow. 

4. Configuring the univer***REMOVED***l connector to read the native audit logs

More detailed information about the workflow for GDP can be found [here](docs/uc_config_gdp.md).

In Guardium Insights, the workflow for deploying the univer***REMOVED***l connector is slightly different, and can be found [here](docs/UC_Configuration_GI.md)

***
**However, the specific steps for each workflow may differ slightly per different data sources. See our [list of of available plugins](https://github.com/IBM/univer***REMOVED***l-connectors/blob/main/docs/available_plugins.md) to view detailed, step-by-step instructions for each supported data source/plug-in**.

**See also: [Using GIM](docs/GIM.md), [Using AWS](docs/aws.md), [Configuring with MongoDB, Filebeat, Syslog, and MYSQL](docs/Migrated_pages.md)**
***

## Monitoring UC connections

The Univer***REMOVED***l connector is monitored via tools that are already familiar to Guardium Data Protection and Guardium Insights users. As well as some unique tools that can be found in the following links. 

 [Monitoring UC connections in Guardium Data Protection](docs/monitoring_GDP.md)

 [Monitoring UC connections in Guardium Insights](/docs/monitoring_GI.MD)

## Policies

With a few Exceptions,  using data from the univer***REMOVED***l connector is no different than using data from any other source in Guardium Data Protection or Guardium Insights. For using the Univer***REMOVED***l Connector in Guardium Data Protection, there are a few unique policies that can be found in this link:

[Configuring Policies for the univer***REMOVED***l connector](docs/uc_policies_gdp.md)


## Known limitations

The univer***REMOVED***l connector has the following known limitations:

### Guardium Data Protection

 * When configuring univer***REMOVED***l connectors, only use port numbers higher than 5000. Use a new port for each future connection.

* S3 SQS and S3 Cloudwatch plug-ins are not supported on IPV6 Guardium systems.

* The DynamoDB plug-in does not support IPV6.

* MySQL plug-ins do not send the DB name to Guardium, if the DB commands are performed by using MySQL native client.

* When connected with a MySQL plug-in, queries for non-existent tables are not logged to GDM_CONSTRUCT.

* MongoDB plug-ins do not send the client source program to Guardium.

* Use only the packages that are supplied by IBM. Do not use extra spaces in the title.

***Limitations associated with specific datasources are described in the UC plugin readme files for each datasource***

### Guardium Insights

Known limitations for Guardium insights can be found in the UC plugin readme files for each datasource



## FAQs

[Here](docs/faqs_gdp.md) is a list of frequently asked questions for Guardium Data Protection. 

[Here](docs/faqs_gi.md) is a list of frequently asked questions for Guardium Insights. 


## Developing plug-ins

Users can develop their own univer***REMOVED***l connector plugins, if needed, and contribute them back to the open source project, if desired.

(In order to overwrite old plug-ins, you can upload a new version from the official IBM Github page. Please make sure that the new plug-in has the exact ***REMOVED***me name as the old version.)

[Here](docs/developing_plugins_gdp.md) is a guide for developing new plug-ins for Guardium Data Protection. 

[Here](docs/developing_plugins_gi.md) is a guide for developing new plug-ins for Guardium Insights. 


***
## Contributing
**To make your connector plug-in available to the community, submit your connector to this repository for IBM Certification. We also accept updates or bug fixes to existing plug-ins, to keep them current:**

- **[Guidelines for contributing](CONTRIBUTING.md)**
- **Benefits include:**

  **- Free, comprehensive testing and certification.**
  
  **- Expanding the reach of product APIs.** 
  
  **- Driving u***REMOVED***ge of a product or solution.**
***

## Contact Us
If you find any problems or want to make suggestions for future features, please create [issues and suggestions on Github](https://github.com/IBM/univer***REMOVED***l-connectors/issues).


## Licensing

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
