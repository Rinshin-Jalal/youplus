/**
 * BigBruh MVP - AI Calls Service
 * Extracts psychological weapons and generates call scripts
 */

import { Env, OnboardingResponse, Identity } from '../types';
import { ElevenLabsService } from './elevenlabs';

export class AICallsService {
  private elevenLabs: ElevenLabsService;

  constructor(env: Env) {
    this.elevenLabs = new ElevenLabsService(env);
  }

  /**
   * Extract psychological weapons from onboarding responses
   */
  async extractPsychologicalWeapons(userId: string, responses: Record<string, OnboardingResponse>, env: Env): Promise<Identity> {
    const weapons: Partial<Identity> = {
      user_id: userId
    };

    // Extract 10 core weapons from onboarding responses
    Object.values(responses).forEach(response => {
      switch (response.dbField) {
        case 'identity_name':
          // Store in identity for personalization
          break;
        case 'biggest_lie':
          weapons.biggest_lie = response.value as string;
          break;
        case 'financial_loss_amount':
          weapons.financial_loss_amount = parseInt(response.value as string);
          break;
        case 'opportunity_cost_voice':
          weapons.opportunity_cost_voice = response.value as string;
          break;
        case 'relationship_damage_type':
          weapons.relationship_damage_type = response.value as string;
          break;
        case 'relationship_moment_voice':
          weapons.relationship_moment_voice = response.value as string;
          break;
        case 'physical_disgust_voice':
          weapons.physical_disgust_voice = response.value as string;
          break;
        case 'physical_disgust_rating':
          weapons.physical_disgust_rating = parseInt(response.value as string);
          break;
        case 'daily_reality_voice':
          weapons.daily_reality_voice = response.value as string;
          break;
        case 'time_vampire_type':
          weapons.time_vampire_type = response.value as string;
          break;
        case 'quit_trigger_emotion':
          weapons.quit_trigger_emotion = response.value as string;
          break;
        case 'intellectual_excuse_voice':
          weapons.intellectual_excuse_voice = response.value as string;
          break;
        case 'accountability_graveyard_count':
          weapons.accountability_graveyard_count = parseInt(response.value as string);
          break;
        case 'accountability_trigger_type':
          weapons.accountability_trigger_type = response.value as string;
          break;
        case 'daily_non_negotiable':
          weapons.daily_non_negotiable = response.value as string;
          break;
        case 'mortality_urgency_voice':
          weapons.mortality_urgency_voice = response.value as string;
          break;
        case 'war_cry_voice':
          weapons.war_cry_voice = response.value as string;
          break;
      }
    });

    // Generate AI-synthesized insights
    weapons.shame_trigger = this.generateShameTrigger(weapons);
    weapons.financial_pain_point = this.generateFinancialPainPoint(weapons);
    weapons.relationship_damage_specific = this.generateRelationshipDamage(weapons);
    weapons.breaking_point_event = this.generateBreakingPoint(weapons);
    weapons.self_sabotage_pattern = this.generateSabotagePattern(weapons);
    weapons.accountability_history = this.generateAccountabilityHistory(weapons);
    weapons.current_self_summary = this.generateCurrentSelfSummary(weapons);
    weapons.aspirational_identity_gap = this.generateAspirationalGap(weapons);
    weapons.non_negotiable_commitment = this.generateNonNegotiableCommitment(weapons);
    weapons.war_cry_or_death_vision = this.generateWarCryOrDeath(weapons);

    return weapons as Identity;
  }

  /**
   * Generate daily call with audio
   */
  async generateDailyCall(identity: Identity, callType: 'STANDARD' | 'SHAME' | 'EMERGENCY' = 'STANDARD', failureCount: number = 0): Promise<{
    script: string;
    audio: ArrayBuffer;
    weapons_deployed: string[];
    estimated_duration: number;
  }> {
    let callGeneration;

    switch (callType) {
      case 'SHAME':
        callGeneration = this.elevenLabs.generateShameCallScript(identity, failureCount);
        break;
      case 'EMERGENCY':
        callGeneration = this.elevenLabs.generateEmergencyCallScript(identity);
        break;
      default:
        callGeneration = this.elevenLabs.generateDailyCallScript(identity);
    }

    const audio = await this.elevenLabs.generateAudio(callGeneration.script);

    return {
      script: callGeneration.script,
      audio,
      weapons_deployed: callGeneration.weapons_deployed,
      estimated_duration: callGeneration.estimated_duration
    };
  }

  // AI-synthesized weapon generators
  private generateShameTrigger(weapons: Partial<Identity>): string {
    if (weapons.physical_disgust_voice && weapons.relationship_damage_type) {
      return `Being the person ${weapons.relationship_damage_type} stopped believing in, while seeing ${weapons.physical_disgust_voice} in the mirror every day`;
    }
    return weapons.physical_disgust_voice || 'The person you fear becoming';
  }

  private generateFinancialPainPoint(weapons: Partial<Identity>): string {
    if (weapons.financial_loss_amount && weapons.opportunity_cost_voice) {
      return `$${weapons.financial_loss_amount} lost this year while missing ${weapons.opportunity_cost_voice}`;
    }
    return `The financial cost of your excuses`;
  }

  private generateRelationshipDamage(weapons: Partial<Identity>): string {
    if (weapons.relationship_damage_type && weapons.relationship_moment_voice) {
      return `${weapons.relationship_damage_type} stopped believing when ${weapons.relationship_moment_voice}`;
    }
    return weapons.relationship_damage_type || 'The people who gave up on you';
  }

  private generateBreakingPoint(weapons: Partial<Identity>): string {
    if (weapons.mortality_urgency_voice) {
      return `Realizing you have limited time: ${weapons.mortality_urgency_voice}`;
    }
    return 'The event that forces you to change';
  }

  private generateSabotagePattern(weapons: Partial<Identity>): string {
    if (weapons.quit_trigger_emotion && weapons.intellectual_excuse_voice) {
      return `When ${weapons.quit_trigger_emotion} hits, you rationalize with "${weapons.intellectual_excuse_voice}" and quit`;
    }
    return 'Your pattern of making excuses and quitting';
  }

  private generateAccountabilityHistory(weapons: Partial<Identity>): string {
    if (weapons.accountability_graveyard_count && weapons.accountability_trigger_type) {
      return `Quit ${weapons.accountability_graveyard_count} systems, only responds to ${weapons.accountability_trigger_type}`;
    }
    return 'Your history of abandoning accountability';
  }

  private generateCurrentSelfSummary(weapons: Partial<Identity>): string {
    const parts = [];
    if (weapons.time_vampire_type) parts.push(`wastes hours on ${weapons.time_vampire_type}`);
    if (weapons.daily_non_negotiable) parts.push(`talks about ${weapons.daily_non_negotiable} but doesn't do it`);
    if (weapons.biggest_lie) parts.push(`tells themselves "${weapons.biggest_lie}" daily`);
    
    if (parts.length > 0) {
      return `Someone who ${parts.join(', ')}`;
    }
    return 'The person you are right now';
  }

  private generateAspirationalGap(weapons: Partial<Identity>): string {
    if (weapons.daily_non_negotiable) {
      return `Wants to be someone who ${weapons.daily_non_negotiable} daily, but currently can't even start`;
    }
    return 'The gap between who you want to be and who you are';
  }

  private generateNonNegotiableCommitment(weapons: Partial<Identity>): string {
    if (weapons.daily_non_negotiable) {
      return `${weapons.daily_non_negotiable} every single day, no excuses`;
    }
    return 'Your commitment to yourself';
  }

  private generateWarCryOrDeath(weapons: Partial<Identity>): string {
    if (weapons.war_cry_voice) {
      return `Scream "${weapons.war_cry_voice}" or die as someone who gave up`;
    }
    return 'Your choice between fighting and quitting';
  }
}
