spool ddl.sql

    @get_tab_ddl.sql ce MedicalFindingType
    @get_tab_ddl.sql ce ProductFindingType

    @get_tab_ddl.sql ce DerivedFact
    @get_tab_ddl.sql ce Recommendation
    @get_tab_ddl.sql ce RecommendationText

    @get_tab_ddl.sql ce MedicalFinding
    @get_tab_ddl.sql ce Clinical_Condition
    @get_tab_ddl.sql ce ProductFinding
    @get_tab_ddl.sql ce DerivedFactProductUsage
    @get_tab_ddl.sql ce ProductOpportunityPoints
    @get_tab_ddl.sql ce OpportunityPointsDiscr

spool off
