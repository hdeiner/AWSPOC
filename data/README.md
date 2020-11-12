### Test Data for the AWSPOC Project

##### Concept

In recognition of the sensitive nature of the data currently stored in the Oracle Database sitting inside the corporate network it is currently encased in, the following are guiding princpals for this project:

<ul>
<li>If confidential records end up in the hands of a person not privy to the information, the consequences can be overwhelming. Breach of medical records could lead to identity theft, which can destroy a person's finances, credit and reputation. Victims could seek litigation against the healthcare practice in which the breach occurred. If the breach affected multiple patients, the practice is headed down a long road of legal tribulations.</li>
<li>Federal legislation, such as HIPAA and the HITECH Act, seek to safeguard protected health information (PHI). In addition, according to the National Conference of State Legislatures, 46 states have data breach notification laws. And, of course, there’s the Consumer Privacy Bill of Rights which affords some level of privacy rights to patients.<BR/><BR/>HIPAA and the Consumer Privacy Bill of Rights, however, create an odd legislative gap. The Consumer Privacy Bill of Rights excludes patients to the extent their health information is covered by HIPAA, while offering greater privacy rights with respect to health information not covered by HIPAA. There is long standing by ANSI and others that uncovered the “inadequacies” of HIPAA, including the fact that the HIPAA Privacy Rule was not even intended by the Department of Health and Human Services to serve as a “best practices” standard for privacy protection.<BR/><BR/>This means that HIPAA-protected PHI does not benefit from the Consumer Privacy Bill of Rights and is subject to the same privacy pitfalls as before. The Health Information Privacy Bill of Rights seeks to “protect the fundamental right to privacy of all Americans and the health information privacy that is essential for quality health care,” with prescriptions for patient control, security, accountability, and other rights.</li>
<li>Patient privacy is a fundamental right that is being challenged as patient records are digitized, and access to those records increases exponentially. The success of our national healthcare ecosystem depends on respecting that right. Patients should not be required to sacrifice their right to privacy in order to obtain health care. Public trust in the health care delivery system cannot be maintained if privacy rights for sensitive health information are weaker than the privacy rights of individuals for less sensitive non-health data.</li>
</ul>

<ul>
<li><B>Make no mistake about it.  We do not want to expose patient data to capture and sale by others.  We want patient data safe with us so we can use it to make money on it for ourselves</B></li>
</ul>

<ul>
<li>We in this project take the above seriously.  Perhaps even more seriously than the corporate concerns being voiced during this development.</li>
<li>To that end, we will not store any data gleaned from the Oracle database that will be used to benchmark alternative databases against in Git and/or GitHub itself.  Due to the size of the data involved, we need reasonable access to this data.  We choose Amazon S3 (simple storage service) as the way to house this data due to latency and the speed of light.</li>
<li>To protect the data itself, we will use PGP 4096 bit public and private keys and AES256 synmetric encryption for all data stored in S3.  See https://en.wikipedia.org/wiki/RSA_(cryptosystem) and https://en.wikipedia.org/wiki/Advanced_Encryption_Standard and https://www.solarwindsmsp.com/blog/aes-256-encryption-algorithm for further information on this and how this is uncrackable by brute force, taking billions of years using current technology.</li>
</ul>

<table>
<tr><th>local file name</th><th>AWS S3 URI</th></tr>
<tr><td>ce.Clinical_Condition.csv</td><td>s3://health-engine-aws-poc/ce.Clinical_Condition.csv</td></tr>
<tr><td>ce.DerivedFact.csv</td><td>s3://health-engine-aws-poc/ce.DerivedFact.csv</td></tr>
<tr><td>ce.DerivedFactProductUsage.csv</td><td>s3://health-engine-aws-poc/ce.DerivedFactProductUsage.csv</td></tr>
<tr><td>ce.MedicalFinding.csv</td><td>s3://health-engine-aws-poc/ce.MedicalFinding.csv</td></tr>
<tr><td>ce.MedicalFindingType.csv</td><td>s3://health-engine-aws-poc/ce.MedicalFindingType.csv</td></tr>
<tr><td>ce.OpportunityPointsDiscr.csv</td><td>s3://health-engine-aws-poc/ce.OpportunityPointsDiscr.csv</td></tr>
<tr><td>ce.ProductFinding.csv</td><td>s3://health-engine-aws-poc/ce.ProductFinding.csv</td></tr>
<tr><td>ce.ProductFindingType.csv</td><td>s3://health-engine-aws-poc/ce.ProductFindingType.csv</td></tr>
<tr><td>ce.ProductOpportunityPoints.csv</td><td>s3://health-engine-aws-poc/ce.ProductOpportunityPoints.csv</td></tr>
<tr><td>ce.Recommendation.csv</td><td>s3://health-engine-aws-poc/ce.Recommendation.csv</td></tr>
</table>
