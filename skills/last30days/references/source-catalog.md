# Source Catalog

Canonical source lists for the domain-specific rows in the main skill. The skill points here rather than inlining long lists. Add sources as you discover them; the skill will pick them up via `References` pointers.

## Consumer-product review aggregators (by category)

| Category               | Canonical publishers                                                                                                                              |
| ---------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Kitchen**            | Wirecutter, Serious Eats, America's Test Kitchen, Cook's Illustrated, Food & Wine, Food Network, Allrecipes, Spruce Eats, Bon Appétit, Epicurious |
| **Audio**              | Wirecutter, RTINGS, SoundGuys, What Hi-Fi, Stereophile, Audioholics                                                                               |
| **Outdoor / gear**     | Wirecutter, Outdoor Gear Lab, GearJunkie, REI Expert Advice, Outside Magazine, Section Hiker, Switchback Travel                                   |
| **Tech / household**   | Wirecutter, Reviewed, The Verge, Consumer Reports, CNET, PCMag, Tom's Hardware, Engadget                                                          |
| **Cars**               | Car and Driver, MotorTrend, Edmunds, Kelley Blue Book, Consumer Reports Auto, Jalopnik (enthusiast)                                               |
| **Books / reading**    | NYT Book Review, The Atlantic Books, Kirkus, Publishers Weekly, Goodreads (community), NYT Best Sellers, Esquire                                  |
| **Fashion / clothing** | The Strategist, Esquire, GQ, Wirecutter, Permanent Style, r/malefashionadvice, Put This On                                                        |

Discovery pattern: `best {TOPIC} 2026 Wirecutter Serious Eats` (or category-appropriate names). Fetch top 2–3 roundup articles directly.

**Absence-is-signal:** zero relevant roundups means community is the authority — demote this class to N/A and promote owner forums + Reddit to tier-1.

---

## Medical / health authoritative sources

| Tier                             | Sources                                                                                                                                                                    |
| -------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Peer-reviewed**                | pubmed.ncbi.nlm.nih.gov, pmc.ncbi.nlm.nih.gov, Cochrane reviews, JAMA Network, NEJM, BMJ, The Lancet                                                                       |
| **Preprints (emerging science)** | biorxiv.org, medrxiv.org, arXiv q-bio                                                                                                                                      |
| **Clinical guidelines**          | ACC/AHA (cardiology), USPSTF (screening), NICE (UK), WHO, SAMHSA (mental health), IDSA (infectious disease), ADA (diabetes), NLA (lipids), ACOG (OB/GYN), AAP (pediatrics) |
| **Clinical centers**             | Mayo Clinic, Cleveland Clinic Journal of Medicine, Johns Hopkins Medicine, NIH patient education, CDC (public-health)                                                      |
| **Clinician media**              | Medscape, JAMA Network, NEJM Journal Watch, The BMJ Opinion, STAT News                                                                                                     |

Canonical query patterns: `"{TOPIC} PubMed"`, `"{TOPIC} Cochrane review"`, `"{TOPIC} 2026 guideline"`, `"{TOPIC} Mayo Clinic"`, `"{TOPIC} FDA label"` (for drug TOPICs).

Credentialed X handles to target: @JAMACardio, @NEJM, @TheLancet, @BMJ_latest, @MedscapeDerm (and similar Medscape specialty accounts), @MayoClinic, @ClevelandClinic, handles with MD/PhD/RN in bio + institutional affiliation.

---

## Sports sources (by shape)

| Source class                    | Examples                                                                                                     |
| ------------------------------- | ------------------------------------------------------------------------------------------------------------ |
| **League official**             | mlssoccer.com, nba.com, nfl.com, mlb.com, premierleague.com, f1.com, wnba.com, nhl.com, tennis.com           |
| **Team official**               | soundersfc.com, lakers.com, etc. — find via `"{team} official site"`                                         |
| **SBN team blogs**              | sounderatheart.com, bluebirdbanter.com, silverscreenandroll.com (Lakers), etc. Find via `"{team} SB Nation"` |
| **Beat writers (The Athletic)** | Find via `"{team} The Athletic"` — named journalist beat reporters                                           |
| **Wire / ESPN**                 | ESPN game pages, Reuters Sport, AP Sports                                                                    |
| **Advanced stats**              | Baseball Savant, FanGraphs, Basketball-Reference, FBref, PFF (football)                                      |

On X: target team/league official handles + beat-writer handles by name. Generic `site:x.com` returns blog-aggregator URLs for sports; use name-specific queries.

On Reddit: explicitly search `r/{TeamName}` (e.g., r/SoundersFC, r/Lakers) and `r/{league}` (r/MLS, r/nba) — default Reddit query often misses these.

Keep YouTube tier-1 (highlights are the medium for sports).

---

## Geopolitics / conflict sources

| Source class                             | Examples                                                                                                                                                                                                   |
| ---------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Wire services**                        | Reuters, AP, AFP, BBC, NPR, Al Jazeera, DW                                                                                                                                                                 |
| **Specialist trackers**                  | Institute for the Study of War (@TheStudyofWar) — daily campaign assessments for active conflicts; Russia Matters Report Card (weekly); DeepState; LiveUAmap; Armed Conflict Location & Event Data (ACLED) |
| **Think tanks**                          | CSIS, CFR, Carnegie Endowment, RAND, Brookings, RUSI, IISS, Atlantic Council, Chatham House                                                                                                                |
| **Credentialed OSINT / analyst handles** | @RALee85 (Rob Lee), @KofmanMichael (Michael Kofman), @Dara_Massicot, @PhillipsPOBrien, plus named journalist beat reporters with institutional bylines                                                     |

Info-ops caveat: expect contamination on contested topics. Attribute contested numbers to their reporting source ("per Ukrainian MoD", "per Chinese MoD") rather than stating as fact.

---

## Daily / weekly trackers (rapidly-evolving events)

| Domain                      | Tracker(s)                                                          |
| --------------------------- | ------------------------------------------------------------------- |
| **War / conflict**          | ISW daily campaign assessments, Russia Matters weekly, LiveUAmap    |
| **Weather / storms**        | NWS, NHC (hurricanes), Weather.gov, ECMWF models                    |
| **Elections**               | Decision Desk HQ, 538, Cook Political Report, Sabato's Crystal Ball |
| **Earthquakes / geology**   | USGS, EMSC                                                          |
| **SEC filings / corporate** | SEC EDGAR, 10-K Wizard, Bamsec                                      |
| **Epidemiology**            | CDC MMWR, WHO situation reports, ECDC                               |
| **Wildfires**               | InciWeb (US), Cal Fire, NASA FIRMS                                  |

One weekly tracker digest is worth many single-day wire hits because the methodology is consistent day-over-day.

---

## Owner / hobbyist forums (canonical examples)

| Domain                      | Canonical forum                                                          |
| --------------------------- | ------------------------------------------------------------------------ |
| Honda Element               | elementownersclub.com                                                    |
| Toyota Tacoma               | tacomaworld.com                                                          |
| Subaru (WRX, etc.)          | nasioc.com                                                               |
| Saab 9-3                    | saabcentral.com, saablink.net                                            |
| Fountain pens               | fountainpennetwork.com                                                   |
| Backcountry hunting         | rokslide.com                                                             |
| Mechanical keyboards        | r/MechanicalKeyboards + Geekhack + Deskthority                           |
| Classic cars                | forums at the make-specific clubs (e.g., mgexp.com, triumph2000register) |
| Audiophile gear             | Head-Fi, What's Best Forum, ASR Forum                                    |
| Photography (specific gear) | DPReview forums, FredMiranda, Rangefinderforum                           |

Discovery pattern: `"{product or vehicle} owners forum"` or `"{product} owners club"`. For niche hobbies, search `"{hobby} forum"` or the enthusiast subreddit's wiki for recommended forums.

---

## LOCATION sources (non-default)

| Source class           | Notes                                                                                                                  |
| ---------------------- | ---------------------------------------------------------------------------------------------------------------------- |
| **Ground News**        | `https://ground.news/interest/{slug}` — city-only slug for international, city-state for US                            |
| **Local papers**       | Fetch 2–3 per mid-size city; search `"{city} newspaper"` or native-language equivalent                                 |
| **City .gov**          | `cityof{x}.gov` / `{city}.{state}.us` — primary for US RFPs, closures, notices                                         |
| **Metro Reddit sub**   | e.g., r/grandrapids for Rockford MI — quote full "City State" phrase to avoid collisions                               |
| **Mil-town specialty** | Stars & Stripes, DVIDS — for US military installations abroad (Vicenza/Aviano, Ramstein, Yokosuka, Bahrain, Stuttgart) |

Non-anglophone places: run a supplemental query in the local language (Italian "cronaca", French "actualités", German "Nachrichten", Japanese "ニュース", etc.). This is almost always the single highest-signal query for hyperlocal content.
