//
//  StepDefinitions.swift
//  bigbruhh
//
//  All 60 psychological onboarding steps (OPTIMIZED - Bloat Elimination v1.0)
//  UPDATED: Optimized from 45 to 60 steps with enhanced explanation/value messaging
//  Added: 15 phase transition bridges, micro-explanations, and commitment confirmations
//  Ratio: 35 questions (58.3%) + 25 explanations (41.7%)
//

import Foundation

// MARK: - Step Definitions Array

let STEP_DEFINITIONS: [StepDefinition] = [
    // PHASE 1: WARNING & INITIATION (Steps 1-7)
    StepDefinition(
        id: 1,
        phase: .warningInitiation,
        type: .explanation,
        prompt: "BIGBRUH ISN'T FOR EVERYONE.\n\nThis isn't friendly.\nYou'll hate it.\n\nBut you'll change.\n\nOr stay stuck:\n- Hating yourself\n- Scrolling endlessly\n- Wasting potential\n- Dying with regrets\n\nChoose now.",
        dbField: nil,
        options: nil,
        helperText: nil,
        sliders: nil,
        minDuration: nil,
        requiredPhrase: nil,
        displayType: nil
    ),

    StepDefinition(
        id: 2,
        phase: .warningInitiation,
        type: .voice,
        prompt: "Why are you REALLY here? Not the bullshit you tell others.",
        dbField: ["voice_commitment"],
        options: nil,
        helperText: nil,
        sliders: nil,
        minDuration: 10,
        requiredPhrase: nil,
        displayType: nil
    ),

    // NEW: Commitment acknowledgment
    StepDefinition(
        id: 3,
        phase: .warningInitiation,
        type: .explanation,
        prompt: "I heard you.\n\"Why you're really here.\"\n\nMost people sound confident.\nIn the recording.\n\nThen they hear it played back.\nAnd realize they were lying.\n\nYour voice will haunt you.\nEvery time you want to quit.\n\nAre you SURE you're ready?\n\nBecause I'm going to use your own words.\nAgainst you.\nWhen you're weak.",
        dbField: nil,
        options: nil,
        helperText: nil,
        sliders: nil,
        minDuration: nil,
        requiredPhrase: nil,
        displayType: nil
    ),

    StepDefinition(
        id: 4,
        phase: .warningInitiation,
        type: .text,
        prompt: "What should I call you?",
        dbField: ["identity_name"],
        options: nil,
        helperText: nil,
        sliders: nil,
        minDuration: nil,
        requiredPhrase: nil,
        displayType: nil
    ),

    StepDefinition(
        id: 5,
        phase: .warningInitiation,
        type: .explanation,
        prompt: "I'm about to expose every excuse, failure, and weak moment.\n\nThe 3 AM lies.\nBroken promises.\nDead dreams.\nWasted opportunities.\n\nThis isn't therapy.\nThis is brutal honesty.\n\nReady?",
        dbField: nil,
        options: nil,
        helperText: nil,
        sliders: nil,
        minDuration: nil,
        requiredPhrase: nil,
        displayType: nil
    ),

    StepDefinition(
        id: 6,
        phase: .warningInitiation,
        type: .voice,
        prompt: "What's the BIGGEST LIE you tell yourself every day?",
        dbField: ["biggest_lie"],
        options: nil,
        helperText: nil,
        sliders: nil,
        minDuration: 7,
        requiredPhrase: nil,
        displayType: nil
    ),

    // NEW: Excuse discovery bridge
    StepDefinition(
        id: 7,
        phase: .warningInitiation,
        type: .explanation,
        prompt: "You just admitted your biggest lie.\nEveryone does.\n\nBut here's the difference:\nMost people confess and feel better.\nYou're about to get WORSE.\n\nBecause I'm going to show you:\n- Your excuse library\n- Your quit pattern\n- Your weakness schedule\n\nAnd you'll see it's all the same.\nEvery. Single. Time.\n\nReady to meet your excuses?",
        dbField: nil,
        options: nil,
        helperText: nil,
        sliders: nil,
        minDuration: nil,
        requiredPhrase: nil,
        displayType: nil
    ),

    // PHASE 2A: EXCUSE DISCOVERY (Steps 8-14)
    StepDefinition(
        id: 8,
        phase: .excuseDiscovery,
        type: .choice,
        prompt: "Which excuse is your favorite?",
        dbField: ["favorite_excuse"],
        options: [
            "I don't have time",
            "I'm too tired",
            "I'll start tomorrow",
            "It's not the right moment",
            "Other people have it easier",
            "Other"
        ],
        helperText: nil,
        sliders: nil,
        minDuration: nil,
        requiredPhrase: nil,
        displayType: nil
    ),

    StepDefinition(
        id: 9,
        phase: .excuseDiscovery,
        type: .voice,
        prompt: "Last time you COMPLETELY GAVE UP on something important. Tell me.",
        dbField: ["last_failure"],
        options: nil,
        helperText: nil,
        sliders: nil,
        minDuration: 10,
        requiredPhrase: nil,
        displayType: nil
    ),

    StepDefinition(
        id: 10,
        phase: .excuseDiscovery,
        type: .explanation,
        prompt: "Confession without change?\nThat's just masturbation.\n\nWe're going deeper.\n\nInto why you quit DAY 3.\nInto why you sabotage success.\n\nReady to kill your weak self?",
        dbField: nil,
        options: nil,
        helperText: nil,
        sliders: nil,
        minDuration: nil,
        requiredPhrase: nil,
        displayType: nil
    ),

    StepDefinition(
        id: 11,
        phase: .excuseDiscovery,
        type: .text,
        prompt: "What's your WEAKNESS WINDOW? Exact time/situation when you fold.",
        dbField: ["weakness_window"],
        options: nil,
        helperText: nil,
        sliders: nil,
        minDuration: nil,
        requiredPhrase: nil,
        displayType: nil
    ),

    StepDefinition(
        id: 12,
        phase: .excuseDiscovery,
        type: .voice,
        prompt: "What are you procrastinating on RIGHT NOW? The thing eating at you.",
        dbField: ["procrastination_now"],
        options: nil,
        helperText: nil,
        sliders: nil,
        minDuration: 8,
        requiredPhrase: nil,
        displayType: nil
    ),

    // NEW: Pattern recognition micro-explanation
    StepDefinition(
        id: 13,
        phase: .excuseDiscovery,
        type: .explanation,
        prompt: "Notice the pattern?\n\nYour FAVORITE excuse.\nYour LAST failure.\nYour CURRENT procrastination.\n\nAll connected.\nAll the same software.\n\nMost people identify ONE excuse.\nYou're seeing the PATTERN.\n\nThis is rare.\nThis is dangerous.\nThis means change is possible.\n\nIf you don't quit.",
        dbField: nil,
        options: nil,
        helperText: nil,
        sliders: nil,
        minDuration: nil,
        requiredPhrase: nil,
        displayType: nil
    ),

    StepDefinition(
        id: 14,
        phase: .excuseDiscovery,
        type: .dualSliders,
        prompt: "Rate your fire right now:",
        dbField: ["motivation_fear_intensity", "motivation_desire_intensity"],
        options: nil,
        helperText: "Numbers don't lie. Weak fuel burns out fast.",
        sliders: [
            SliderConfig(
                label: "How much you HATE failing (1-10)",
                range: SliderConfig.SliderRange(min: 1, max: 10)
            ),
            SliderConfig(
                label: "How BAD you want to win (1-10)",
                range: SliderConfig.SliderRange(min: 1, max: 10)
            )
        ],
        minDuration: nil,
        requiredPhrase: nil,
        displayType: nil
    ),

    // PHASE 2B: CONSEQUENCE CONFRONTATION (Steps 15-20)
    // NEW: Consequence transition bridge
    StepDefinition(
        id: 15,
        phase: .excuseConfrontation,
        type: .explanation,
        prompt: "Your fire levels?\nRecorded.\n\nBut motivation is a LIE.\nIt comes and goes.\n\nWhat matters is CONSEQUENCE.\n\nThe REAL pain you're avoiding:\n- Mirror shame\n- Relationship damage\n- The person you're becoming\n\nTime to see what you're ACTUALLY losing.",
        dbField: nil,
        options: nil,
        helperText: nil,
        sliders: nil,
        minDuration: nil,
        requiredPhrase: nil,
        displayType: nil
    ),

    StepDefinition(
        id: 16,
        phase: .excuseConfrontation,
        type: .choice,
        prompt: "What's KILLING your potential?",
        dbField: ["time_waster"],
        options: [
            "Social media scrolling",
            "YouTube/Netflix binging",
            "Gaming",
            "Porn",
            "Overthinking without action",
            "Other"
        ],
        helperText: nil,
        sliders: nil,
        minDuration: nil,
        requiredPhrase: nil,
        displayType: nil
    ),

    StepDefinition(
        id: 17,
        phase: .excuseConfrontation,
        type: .explanation,
        prompt: "Pathetic.\n\nYou know what to do.\nYou don't do it.\n\nBigBruh is watching.\nHe's disgusted.\n\nYou're becoming the cautionary tale.",
        dbField: nil,
        options: nil,
        helperText: nil,
        sliders: nil,
        minDuration: nil,
        requiredPhrase: nil,
        displayType: nil
    ),

    StepDefinition(
        id: 18,
        phase: .excuseConfrontation,
        type: .voice,
        prompt: "Describe the LOSER VERSION of yourself you're terrified of becoming.",
        dbField: ["fear_version"],
        options: nil,
        helperText: nil,
        sliders: nil,
        minDuration: 8,
        requiredPhrase: nil,
        displayType: nil
    ),

    StepDefinition(
        id: 19,
        phase: .excuseConfrontation,
        type: .voice,
        prompt: "Who STOPPED BELIEVING in you? When did you notice they gave up?",
        dbField: ["relationship_damage"],
        options: nil,
        helperText: nil,
        sliders: nil,
        minDuration: 8,
        requiredPhrase: nil,
        displayType: nil
    ),

    StepDefinition(
        id: 20,
        phase: .excuseConfrontation,
        type: .voice,
        prompt: "Look in the MIRROR right now. What do you see that disgusts you?",
        dbField: ["physical_disgust_trigger"],
        options: nil,
        helperText: nil,
        sliders: nil,
        minDuration: 8,
        requiredPhrase: nil,
        displayType: nil
    ),

    // PHASE 3A: REALITY EXTRACTION (Steps 21-26)
    // NEW: Data vs feelings bridge
    StepDefinition(
        id: 21,
        phase: .patternAwareness,
        type: .explanation,
        prompt: "You felt that.\nIn the mirror.\nThat's real.\n\nBut feelings without DATA?\nThat's just self-pity.\n\nNow I need NUMBERS:\n- Where your time went yesterday\n- How many times you've quit this year\n- The ONE thing you'll actually do\n\nFeelings lie.\nNumbers don't.",
        dbField: nil,
        options: nil,
        helperText: nil,
        sliders: nil,
        minDuration: nil,
        requiredPhrase: nil,
        displayType: nil
    ),

    StepDefinition(
        id: 22,
        phase: .patternAwareness,
        type: .explanation,
        prompt: "You know the formula.\nBut you're still here.\nSame weight. Same excuses.\n\nYour competition is winning.\nWhile you download apps.\n\nStill want to continue?",
        dbField: nil,
        options: nil,
        helperText: nil,
        sliders: nil,
        minDuration: nil,
        requiredPhrase: nil,
        displayType: nil
    ),

    StepDefinition(
        id: 23,
        phase: .patternAwareness,
        type: .voice,
        prompt: "Describe YESTERDAY hour by hour. Where did your time actually go?",
        dbField: ["daily_time_audit"],
        options: nil,
        helperText: nil,
        sliders: nil,
        minDuration: 10,
        requiredPhrase: nil,
        displayType: nil
    ),

    StepDefinition(
        id: 24,
        phase: .patternAwareness,
        type: .text,
        prompt: "How many times have you STARTED FRESH this year? Give me the number.",
        dbField: ["quit_counter"],
        options: nil,
        helperText: nil,
        sliders: nil,
        minDuration: nil,
        requiredPhrase: nil,
        displayType: nil
    ),

    StepDefinition(
        id: 25,
        phase: .patternAwareness,
        type: .text,
        prompt: "Pick ONE thing you'll do EVERY SINGLE DAY. No excuses.",
        dbField: ["daily_non_negotiable"],
        options: nil,
        helperText: nil,
        sliders: nil,
        minDuration: nil,
        requiredPhrase: nil,
        displayType: nil
    ),

    StepDefinition(
        id: 26,
        phase: .patternAwareness,
        type: .explanation,
        prompt: "Specific commitment.\nRare.\n\nBut I've heard this 247 times.\n\nThey all said 'this time is different.'\n\nWhere are they now?\nSame couch. Just older.\n\nYou're different though, right?",
        dbField: nil,
        options: nil,
        helperText: nil,
        sliders: nil,
        minDuration: nil,
        requiredPhrase: nil,
        displayType: nil
    ),

    // PHASE 3B: PATTERN ANALYSIS (Steps 27-34)
    // NEW: Pattern analysis transition
    StepDefinition(
        id: 27,
        phase: .patternAnalysis,
        type: .explanation,
        prompt: "\"This time is different.\"\n\nI've heard it 247 times.\nFrom people smarter than you.\nStronger than you.\nMore motivated than you.\n\nThey all had your commitment.\n\nThe difference?\nI'm going to find your PATTERN.\nThe hidden software running your life.\n\nFinancial costs.\nIntellectual excuses.\nParental guilt.\n\nLet's see what ACTUALLY controls you.",
        dbField: nil,
        options: nil,
        helperText: nil,
        sliders: nil,
        minDuration: nil,
        requiredPhrase: nil,
        displayType: nil
    ),

    StepDefinition(
        id: 28,
        phase: .patternAnalysis,
        type: .voice,
        prompt: "How much MONEY have you NOT MADE because of your excuses this year?",
        dbField: ["financial_consequence"],
        options: nil,
        helperText: nil,
        sliders: nil,
        minDuration: 8,
        requiredPhrase: nil,
        displayType: nil
    ),

    // NEW: Financial significance micro-explanation
    StepDefinition(
        id: 29,
        phase: .patternAnalysis,
        type: .explanation,
        prompt: "Money not made.\nOpportunities missed.\nYears wasted.\n\nThat number you just said?\nThat's not just dollars.\n\nThat's:\n- Freedom you don't have\n- Respect you haven't earned\n- Security you can't provide\n\nFinancial consequences are IDENTITY consequences.\n\nEvery dollar you didn't make?\nSomeone else made it.\n\nWhile you scrolled.",
        dbField: nil,
        options: nil,
        helperText: nil,
        sliders: nil,
        minDuration: nil,
        requiredPhrase: nil,
        displayType: nil
    ),

    StepDefinition(
        id: 30,
        phase: .patternAnalysis,
        type: .voice,
        prompt: "What excuse makes YOU sound smart but is still complete bullshit?",
        dbField: ["intellectual_excuse"],
        options: nil,
        helperText: nil,
        sliders: nil,
        minDuration: 7,
        requiredPhrase: nil,
        displayType: nil
    ),

    StepDefinition(
        id: 31,
        phase: .patternAnalysis,
        type: .voice,
        prompt: "What did your PARENTS SACRIFICE for you that you're wasting?",
        dbField: ["parental_sacrifice"],
        options: nil,
        helperText: nil,
        sliders: nil,
        minDuration: 8,
        requiredPhrase: nil,
        displayType: nil
    ),

    StepDefinition(
        id: 32,
        phase: .patternAnalysis,
        type: .choice,
        prompt: "What ACTUALLY makes you move?",
        dbField: ["accountability_style"],
        options: [
            "Fear of public shame",
            "Harsh confrontation",
            "Disappointing someone I respect",
            "Competition",
            "Financial loss",
            "Social consequences"
        ],
        helperText: nil,
        sliders: nil,
        minDuration: nil,
        requiredPhrase: nil,
        displayType: nil
    ),

    StepDefinition(
        id: 33,
        phase: .patternAnalysis,
        type: .explanation,
        prompt: "You know what pisses me off?\nYou have EVERYTHING.\n\nMore opportunity than kings had.\nMore time than you admit.\n\nBut you choose TikTok.\nYou choose NOTHING.\n\nYour ancestors are watching.\nThey're ashamed.",
        dbField: nil,
        options: nil,
        helperText: nil,
        sliders: nil,
        minDuration: nil,
        requiredPhrase: nil,
        displayType: nil
    ),

    StepDefinition(
        id: 34,
        phase: .patternAnalysis,
        type: .voice,
        prompt: "Tell me about ONE TIME you actually followed through. What was different?",
        dbField: ["success_memory"],
        options: nil,
        helperText: nil,
        sliders: nil,
        minDuration: 7,
        requiredPhrase: nil,
        displayType: nil
    ),

    // PHASE 4A: IDENTITY REBUILD (Steps 35-41)
    // NEW: Identity rebuild transition
    StepDefinition(
        id: 35,
        phase: .identityRebuild,
        type: .explanation,
        prompt: "You just described success.\nONE time you followed through.\n\nThat person still exists inside you.\nBuried under excuses.\nSuffocating under comfort.\n\nNow I'm going to EXTRACT them.\n\nWHO you want to become.\nWHAT proves you changed.\nWHAT event would force you.\n\nBecause hoping doesn't work.\nPlanning does.",
        dbField: nil,
        options: nil,
        helperText: nil,
        sliders: nil,
        minDuration: nil,
        requiredPhrase: nil,
        displayType: nil
    ),

    StepDefinition(
        id: 36,
        phase: .identityRebuild,
        type: .voice,
        prompt: "WHO do you want to become in one year? Not goals. WHO you want to BE.",
        dbField: ["identity_goal"],
        options: nil,
        helperText: nil,
        sliders: nil,
        minDuration: 7,
        requiredPhrase: nil,
        displayType: nil
    ),

    StepDefinition(
        id: 37,
        phase: .identityRebuild,
        type: .explanation,
        prompt: "That person you described?\n\nThey exist.\nIn a universe where you didn't quit.\n\nThey wake up laughing.\nRemembering when they were weak like you.\n\nThey're trapped inside you.\nScreaming.\n\nI hear them.\n\nDo you?",
        dbField: nil,
        options: nil,
        helperText: nil,
        sliders: nil,
        minDuration: nil,
        requiredPhrase: nil,
        displayType: nil
    ),

    StepDefinition(
        id: 38,
        phase: .identityRebuild,
        type: .text,
        prompt: "ONE MEASURABLE NUMBER proving you changed. \"Lose 20lbs by June 1st\"",
        dbField: ["success_metric"],
        options: nil,
        helperText: "Specific. Measurable. Real.",
        sliders: nil,
        minDuration: nil,
        requiredPhrase: nil,
        displayType: nil
    ),

    StepDefinition(
        id: 39,
        phase: .identityRebuild,
        type: .voice,
        prompt: "What would have to HAPPEN for you to actually change? Not hope. What EVENT?",
        dbField: ["breaking_point"],
        options: nil,
        helperText: nil,
        sliders: nil,
        minDuration: 8,
        requiredPhrase: nil,
        displayType: nil
    ),

    // NEW: Breaking point acknowledgment
    StepDefinition(
        id: 40,
        phase: .identityRebuild,
        type: .explanation,
        prompt: "You just described your breaking point.\nThe EVENT that would force you to change.\n\nDeath.\nDivorce.\nDisease.\nFinancial collapse.\n\nYou're waiting for CATASTROPHE.\nTo give you permission to try.\n\nPathetic.\n\nBut also POWERFUL.\n\nBecause you just admitted:\nYou already know what's coming.\nIf you don't change.\n\nYou HEARD yourself say it.\nAcknowledge that.",
        dbField: nil,
        options: nil,
        helperText: nil,
        sliders: nil,
        minDuration: nil,
        requiredPhrase: nil,
        displayType: nil
    ),

    StepDefinition(
        id: 41,
        phase: .identityRebuild,
        type: .voice,
        prompt: "What's the ONE PATTERN that always defeats you? Name your enemy.",
        dbField: ["biggest_enemy"],
        options: nil,
        helperText: nil,
        sliders: nil,
        minDuration: 6,
        requiredPhrase: nil,
        displayType: nil
    ),

    // PHASE 4B: COMMITMENT SYSTEM (Steps 42-50)
    // NEW: System vs willpower bridge
    StepDefinition(
        id: 42,
        phase: .commitmentSystem,
        type: .explanation,
        prompt: "You know WHO you want to be.\nYou know WHAT you're fighting.\n\nBut knowing changes NOTHING.\n\nStatistics don't lie:\n- 90% quit by Day 7\n- 99% quit by Day 30\n\nWhy?\nThey had no SYSTEM.\nNo external accountability.\nNo consequence for quitting.\n\nTime to build your cage.",
        dbField: nil,
        options: nil,
        helperText: nil,
        sliders: nil,
        minDuration: nil,
        requiredPhrase: nil,
        displayType: nil
    ),

    StepDefinition(
        id: 43,
        phase: .commitmentSystem,
        type: .explanation,
        prompt: "90% quit Day 7.\n99% quit Day 30.\n\nThey all thought they were special.\n\nNow they're NPCs.\nIn their own life.\n\nThe 1% aren't special.\nThey just didn't quit.\n\nAre you the 99%?",
        dbField: nil,
        options: nil,
        helperText: nil,
        sliders: nil,
        minDuration: nil,
        requiredPhrase: nil,
        displayType: nil
    ),

    StepDefinition(
        id: 44,
        phase: .commitmentSystem,
        type: .text,
        prompt: "How many accountability apps/coaches/systems have you ALREADY QUIT?",
        dbField: ["accountability_graveyard"],
        options: nil,
        helperText: nil,
        sliders: nil,
        minDuration: nil,
        requiredPhrase: nil,
        displayType: nil
    ),

    StepDefinition(
        id: 45,
        phase: .commitmentSystem,
        type: .voice,
        prompt: "You have 10 YEARS left to live. What changes TODAY?",
        dbField: ["urgency_mortality"],
        options: nil,
        helperText: nil,
        sliders: nil,
        minDuration: 8,
        requiredPhrase: nil,
        displayType: nil
    ),

    StepDefinition(
        id: 46,
        phase: .commitmentSystem,
        type: .choice,
        prompt: "What EMOTION makes you quit?",
        dbField: ["emotional_quit_trigger"],
        options: [
            "Boredom",
            "Frustration",
            "Fear of success",
            "Anxiety",
            "Loneliness",
            "Anger at myself"
        ],
        helperText: nil,
        sliders: nil,
        minDuration: nil,
        requiredPhrase: nil,
        displayType: nil
    ),

    StepDefinition(
        id: 47,
        phase: .commitmentSystem,
        type: .text,
        prompt: "How many days STRAIGHT before you've proven you're different? 30? 60? 100?",
        dbField: ["streak_target"],
        options: nil,
        helperText: nil,
        sliders: nil,
        minDuration: nil,
        requiredPhrase: nil,
        displayType: nil
    ),

    // NEW: Streak psychology micro-explanation
    StepDefinition(
        id: 48,
        phase: .commitmentSystem,
        type: .explanation,
        prompt: "You just picked your streak target.\n\n30 days? 60? 100?\n\nHere's the truth:\nThe number doesn't matter.\n\nDAY 3 matters.\nThat's when motivation dies.\n\nDAY 7 matters.\nThat's when 90% quit.\n\nDAY 30 matters.\nThat's when your brain rewires.\n\nEvery day is a DATA POINT.\nProving you're different.\nOr proving you're the same.\n\nWhich dataset are you building?",
        dbField: nil,
        options: nil,
        helperText: nil,
        sliders: nil,
        minDuration: nil,
        requiredPhrase: nil,
        displayType: nil
    ),

    StepDefinition(
        id: 49,
        phase: .commitmentSystem,
        type: .choice,
        prompt: "What are you WILLING TO SACRIFICE?",
        dbField: ["sacrifice_list"],
        options: [
            "Comfort",
            "Excuses",
            "Toxic friends",
            "Entertainment",
            "The need to be liked",
            "All of the above"
        ],
        helperText: nil,
        sliders: nil,
        minDuration: nil,
        requiredPhrase: nil,
        displayType: nil
    ),

    // PHASE 4C: WAR MODE (Steps 50-54)
    // NEW: War cry setup bridge
    StepDefinition(
        id: 50,
        phase: .commitmentSystem,
        type: .explanation,
        prompt: "You just picked your sacrifices.\nMost people lie here.\n\n\"I'll sacrifice comfort.\"\nThen quit when it's uncomfortable.\n\nBut YOU'RE DIFFERENT, right?\n\nProve it.\nCreate your WAR CRY.\n\nThe phrase that pulls you back.\nWhen you're weak.\nWhen you're ready to quit.\n\nNot a mantra.\nA WEAPON.",
        dbField: nil,
        options: nil,
        helperText: nil,
        sliders: nil,
        minDuration: nil,
        requiredPhrase: nil,
        displayType: nil
    ),

    StepDefinition(
        id: 51,
        phase: .commitmentSystem,
        type: .voice,
        prompt: "Create your WAR CRY. What will you scream when you want to quit?",
        dbField: ["war_cry"],
        options: nil,
        helperText: nil,
        sliders: nil,
        minDuration: 8,
        requiredPhrase: nil,
        displayType: nil
    ),

    // NEW: War cry acknowledgment
    StepDefinition(
        id: 52,
        phase: .commitmentSystem,
        type: .explanation,
        prompt: "Your war cry is recorded.\nYour voice. Your words.\n\nNOT mine.\nYOURS.\n\nWhen you want to quit Day 7.\nI'll play it back.\n\nWhen you're lying about being \"too tired.\"\nI'll play it back.\n\nWhen you're about to break your promise.\nI'll play it back.\n\nThis is WHO YOU SAID you are.\nOn this day.\n\nConfirm you heard yourself.\nThis is your identity now.",
        dbField: nil,
        options: nil,
        helperText: nil,
        sliders: nil,
        minDuration: nil,
        requiredPhrase: nil,
        displayType: nil
    ),

    StepDefinition(
        id: 53,
        phase: .commitmentSystem,
        type: .explanation,
        prompt: "I'm not your friend.\nI'm your last shot.\n\nThe brother who sees through your bullshit.\n\nI'll call when you're weak.\nI'll document every excuse.\n\nBecause you've proven several times:\nYou can't do it alone.",
        dbField: nil,
        options: nil,
        helperText: nil,
        sliders: nil,
        minDuration: nil,
        requiredPhrase: nil,
        displayType: nil
    ),

    // PHASE 5A: EXTERNAL ANCHORS (Steps 54-58)
    // NEW: External accountability bridge
    StepDefinition(
        id: 54,
        phase: .externalAnchors,
        type: .explanation,
        prompt: "I'm not your friend.\nI'm your STRUCTURE.\n\nInternal motivation?\nDead in 72 hours.\n\nYou need EXTERNAL accountability:\n- Daily calls you can't ignore\n- Someone who'll be disappointed\n- A failure limit you can't exceed\n\nThis isn't self-help.\nThis is ENGINEERING.\n\nLet's build your cage.",
        dbField: nil,
        options: nil,
        helperText: nil,
        sliders: nil,
        minDuration: nil,
        requiredPhrase: nil,
        displayType: nil
    ),

    StepDefinition(
        id: 55,
        phase: .externalAnchors,
        type: .timeWindowPicker,
        prompt: "What time should I call you EVERY NIGHT to verify you kept your promise?",
        dbField: ["evening_call_time"],
        options: nil,
        helperText: nil,
        sliders: nil,
        minDuration: nil,
        requiredPhrase: nil,
        displayType: nil
    ),

    StepDefinition(
        id: 56,
        phase: .externalAnchors,
        type: .text,
        prompt: "Who would be most DISAPPOINTED to learn you quit again? Give me their name.",
        dbField: ["external_judge"],
        options: nil,
        helperText: nil,
        sliders: nil,
        minDuration: nil,
        requiredPhrase: nil,
        displayType: nil
    ),

    StepDefinition(
        id: 57,
        phase: .externalAnchors,
        type: .choice,
        prompt: "How many failures should I tolerate?",
        dbField: ["failure_threshold"],
        options: ["3 strikes", "5 strikes", "1 strike - no mercy"],
        helperText: nil,
        sliders: nil,
        minDuration: nil,
        requiredPhrase: nil,
        displayType: nil
    ),

    // PHASE 5B: FINAL SEALING (Steps 58-60)
    // NEW: System summary bridge
    StepDefinition(
        id: 58,
        phase: .externalAnchors,
        type: .explanation,
        prompt: "System configured:\n✓ Daily call scheduled\n✓ External judge identified\n✓ Failure threshold set\n\nNow there's no escape.\n\nEvery day:\nI call. You answer.\nYou report. I judge.\n\nEvery failure:\nDocumented.\nNumbered.\nRemembered.\n\nLast chance to run.\nOr stay and PROVE you're different.\n\nChoose now.",
        dbField: nil,
        options: nil,
        helperText: nil,
        sliders: nil,
        minDuration: nil,
        requiredPhrase: nil,
        displayType: nil
    ),

    StepDefinition(
        id: 59,
        phase: .externalAnchors,
        type: .explanation,
        prompt: "Last chance to run.\n\nAfter this, you're mine.\n\nEvery failure tracked.\nEvery excuse numbered.\n\nNo ghosting when I call.\nNo crying when I'm harsh.\n\nThis is voluntary prison.\nI'm the warden.\n\nEnter?",
        dbField: nil,
        options: nil,
        helperText: nil,
        sliders: nil,
        minDuration: nil,
        requiredPhrase: nil,
        displayType: nil
    ),

    StepDefinition(
        id: 60,
        phase: .externalAnchors,
        type: .voice,
        prompt: "Record your OATH. Start with \"I swear that I will...\" Make it binding.",
        dbField: ["oath_recording"],
        options: nil,
        helperText: nil,
        sliders: nil,
        minDuration: 6,
        requiredPhrase: nil,
        displayType: nil
    )
]

// MARK: - Helper Functions

extension Array where Element == StepDefinition {
    func step(withId id: Int) -> StepDefinition? {
        return first { $0.id == id }
    }

    func steps(inPhase phase: OnboardingPhase) -> [StepDefinition] {
        return filter { $0.phase == phase }
    }

    var totalSteps: Int {
        return count
    }
}
