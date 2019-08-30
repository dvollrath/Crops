---
title: Replies to reviewer comments
author: T. Ryan Johnson and Dietrich Vollrath
date: August 2019
---

This is a consolidated reply, given the situation where you allowed us to pass along prior referee reports. We have grouped the topics or questions from all reviewers, to the extent we could. For some specific points, we included the original referee text, and our reply. 


### Identification
The primary concern across all referees was in the identification of the land elasticity. Without rehashing the entire setup, the key assumptions are that labor and goods are mobile *between* districts within states. With that assumption, most of the potential confounding variables (e.g. the agricultural wage and the relative price of agricultural goods) get swept up in state fixed effects, and we can identify the land elasticity from the relationship of agricultural productivity and the labor/land ratio. 

In the absence of the mobility of labor and goods, the referees (and your) intuition that our estimates would be biased towards zero is correct. If each district is autarkic, then there is no necessary relationship at all in the cross-section between labor/land ratios and productivity, and hence you would get estimates close to zero. The obvious concern is that in tropical areas there are more restrictions on mobility, for whatever reason, and that explains the low estimated land elasticities. 

So the core change to the paper was to document and justify the assumption of mobility across districts that allows us to use the state fixed effects to handle the unoberved (but common to all districts within a state) wage and relative price. The new section 2 of the paper provides that evidence, which we felt needed to come before the empirical set-up so that the source of the assumptions was clear. We do a few things there:

1. Provide much more detailed summary statistics on the size (both population and area) of districts, both in absolute terms and relative to their states. The point of these statistics is to show that districts are very small units, with a median population of only 26,000 people, and a median share of state population of only 2%.
2. We show many districts are so small that many are almost purely rural. The median district contains zero percent of the state urban population, and about one-third of our districts have no reported urban population. The median district has about 5,500 urban residents.
3. We discuss the results in Young's recent paper on urban/rural migration, which documents the substantial movement of people back and forth between those areas, and how the data is consistent with an equalization of wages (per unit of human capital) across those areas. Further, we discuss results in a working paper by Hicks, Kleemans, Yi, and Miguel showing similar results using longitudinal data. They have individual level controls for human capital (including a crude IQ proxy) and show that conditional on that, wages are equalized, and also that movement is substantial between urban and rural areas.
4. We use the universe of DHS surveys to look at the questions on migration, mimicking to some degree what Young did in his paper. This allows us to document that within developing countries a substantial number of people have moved at some point in their life, and that the share moving recently (last 5 years) is also substantial. Further, for a subset of those DHS surveys we have some information on place of origin, and show there is regular movement of people from rural to urban and urban to rural.

Combined, we use that to justify a conclusion that there is movement across districts within states. The substantial movement of people from rural to urban areas (and in reverse) and the wage equalization documented by Young and Hicks et al suggests free mobility between urban and rural areas. As many or most districts within states (in particular in developing countries) have negligible urban areas, then urban/rural movement necessarily implies movement between districts. Layed on top of that is the absolute small size of these districts, and it appears to us an entirely plausible assumption that mobility between districts occurs.

In specific cases, the mobility assumption may not hold. The obvious example being China. We can exclude them from the regressions, with no change in results. We can also restrict ourselves only to those countries that have the DHS data that shows movement, and the results hold. 

We think the new Section 3 of the paper, which lays out the theoretical setting to derive the estimation equation, is now more clear. It takes the assumptions generated in Section 2, and shows how applying them to our setting allows us to control for unobservables by using state fixed effects. 

This doesn't get us totally out of the woods, however. We assume that capital can move within a district, but not across districts. That means that the district-specific capital/labor ratio could be a confounder. For that, we propose that night lights will control for that. Further, our robustness check for a sub-sample of districts where we have DHS data uses household level physical capital and human capital measures to control for capital/labor as well. The results are unchanged with these controls.

### Alternative estimation strategies
This paper is effectively estimating a production function, albeit only one parameter of it. As several reviewers noted, there is a deep and thorough literature on doing this from a firm (or possibly farm) level. They wonder why we don't approach the question that way. A few thoughts on this:

1. The short answer is that they're asking for an entirely different paper. No, we don't use firm-level techniques (Olley-Pakes, Ackerberg-Caves-Frasier) because we don't have units of observation (districts) that have panel data on output and *all* inputs to production. Hence we came up with this methodology, which essentially is to look at as small units as possible, to come up with estimates. It isn't a standard technique because the standard technique didn't apply to this setting. 
2. We could apply firm-level techniques to farm-level panel data. But then we'd be estimating farm-level production functions in a limited number of contexts. We want to estimate an aggregate elasticity, which need not be identical to the farm-level elasticity. And if there was variation between farm-level results in tropical and temperate contexts, we wouldn't have enough results to know if that represented systematic variation in the elasticities between those geographic areas. 

There isn't anything we can really "fix" here, without starting from scratch. 

### Aggregated elasticities
A few reviewers wanted a better summary of the elasticity results at the country level. This is subject to a number of caveats, but the indication from reviewers was that those caveats were acceptable given the interest in those numbers. Hence we've now provided an appendix table (it seemed a bit long for the main paper) which shows the aggregate land elasticity. 

In addition, a map of these results was suggested by several reviewers. We've made two that may be of interest.

1. A map showing just the districts that we classify as "Temperate" or "Tropical" and use in the baseline regression. 
2. A map showing an aggregate elasticity for each country.

### The full model
There are both small and large issues here. The large issue is that some reviewers don't see the need for the fully specified model, as the conclusion seems obvious. It could be replaced with a few paragraphs explaining the intuition. We've kept the model in the paper in this draft, but this is something we'd be happy to move to the appendix. 

On the small issues:
1. The interpretation of the Boppart preferences, and whether ag/non-ag are considered substitutes or complements
2. 


### Data sources and timing
Several referees expressed concern with the HYDE population data, given the underlying data sources. The prior version showed results were robust to both GRUMP (associated with the CIESIN gridded population of the world project) or IPUMS, but in this version we've made the GRUMP data the baseline. This in fact shows stronger results than before.

One additional question about the population data dealt with timing, and why we used 2000 (rather than 2010). In the case of GRUMP, 2000 is the latest version available, so there is no alternative. HYDE has a later iteration, but for consistency we show robustness of our results using HYDE 2000. We also show that results are robust to using GRUMP from 1990 (their earliest version). 

### Crop types
Yes, it's about staples. We aren't looking at actual crop output, so we can distinguish cropped area for staples. Why? Because that is probably a more interesting number long run (and might useful historically). f