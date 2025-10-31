/**
 * BigBruh MVP - ElevenLabs Service
 */

import { Env } from '../types';

export interface CallGeneration {
  script: string;
  weapons_deployed: string[];
  estimated_duration: number;
}

export class ElevenLabsService {
  private apiKey: string;
  private voiceId: string;

  constructor(env: Env) {
    this.apiKey = env.ELEVENLABS_API_KEY;
    this.voiceId = env.ELEVENLABS_VOICE_ID || 'adam'; // Default voice
  }

  /**
   * Generate audio from text using ElevenLabs
   */
  async generateAudio(text: string, voiceId?: string): Promise<ArrayBuffer> {
    const response = await fetch(`https://api.elevenlabs.io/v1/text-to-speech/${voiceId || this.voiceId}`, {
      method: 'POST',
      headers: {
        'Accept': 'audio/mpeg',
        'Content-Type': 'application/json',
        'xi-api-key': this.apiKey,
      },
      body: JSON.stringify({
        text: text,
        model_id: 'eleven_monolingual_v1',
        voice_settings: {
          stability: 0.75,
          similarity_boost: 0.75,
        },
      }),
    });

    if (!response.ok) {
      throw new Error(`ElevenLabs API error: ${response.statusText}`);
    }

    return response.arrayBuffer();
  }

  /**
   * Generate daily call script based on user's psychological weapons
   */
  generateDailyCallScript(identity: any): CallGeneration {
    const weapons: string[] = [];
    let script = '';

    // Opening
    script += `Hey ${identity.identity_name || 'there'}. It's BigBruh.\n\n`;

    // Weapon 1: Financial Shame
    if (identity.financial_loss_amount && identity.financial_loss_amount > 0) {
      weapons.push('financial_pain');
      script += `You said you lost $${identity.financial_loss_amount} this year due to your excuses. `;
      if (identity.opportunity_cost_voice) {
        script += `You missed out on ${identity.opportunity_cost_voice}. `;
      }
      script += `Still think that was worth it?\n\n`;
    }

    // Weapon 2: Relationship Damage
    if (identity.relationship_damage_type) {
      weapons.push('relationship_damage');
      script += `${identity.relationship_damage_type} stopped believing in you. `;
      if (identity.relationship_moment_voice) {
        script += `Remember when ${identity.relationship_moment_voice}?\n\n`;
      }
    }

    // Weapon 3: Physical Disgust
    if (identity.physical_disgust_voice) {
      weapons.push('physical_disgust');
      script += `Look in the mirror. You told me you see "${identity.physical_disgust_voice}". `;
      script += `Still disgusted with yourself?\n\n`;
    }

    // Weapon 4: Time Audit
    if (identity.time_vampire_type) {
      weapons.push('time_audit');
      script += `Yesterday you wasted hours on ${identity.time_vampire_type}. `;
      script += `How much more time will you waste?\n\n`;
    }

    // Weapon 5: Accountability History
    if (identity.accountability_graveyard_count && identity.accountability_graveyard_count > 0) {
      weapons.push('accountability_history');
      script += `You've already quit ${identity.accountability_graveyard_count} accountability systems. `;
      script += `What makes this time different?\n\n`;
    }

    // The Core Question
    script += `Enough talk. `;
    script += `Did you keep your promise to ${identity.daily_non_negotiable || 'do what you said'} today?\n\n`;
    script += `YES or NO.`;

    // Calculate estimated duration (rough estimate: 150 words per minute)
    const wordCount = script.split(' ').length;
    const estimatedDuration = Math.ceil((wordCount / 150) * 60); // in seconds

    return {
      script,
      weapons_deployed: weapons,
      estimated_duration: estimatedDuration
    };
  }

  /**
   * Generate shame call script (for when user fails)
   */
  generateShameCallScript(identity: any, failureCount: number): CallGeneration {
    const weapons: string[] = [];
    let script = '';

    // Opening (more aggressive)
    script += `Seriously again, ${identity.identity_name || 'there'}? BigBruh here.\n\n`;

    // Weapon 1: Pattern Recognition
    if (identity.self_sabotage_pattern) {
      weapons.push('pattern_recognition');
      script += `This is exactly your pattern: "${identity.self_sabotage_pattern}". `;
      script += `Day ${failureCount} and you're already proving yourself right.\n\n`;
    }

    // Weapon 2: War Cry
    if (identity.war_cry_voice) {
      weapons.push('war_cry');
      script += `Remember your war cry? "${identity.war_cry_voice}". `;
      script += `Scream it right now because you need it.\n\n`;
    }

    // Weapon 3: Mortality Urgency
    if (identity.mortality_urgency_voice) {
      weapons.push('mortality_urgency');
      script += `You told me "${identity.mortality_urgency_voice}". `;
      script += `Every day you waste is one less day you have.\n\n`;
    }

    // Weapon 4: Aspiration Gap
    if (identity.aspirational_identity_gap) {
      weapons.push('aspiration_gap');
      script += `You want to be "${identity.aspirational_identity_gap}". `;
      script += `But you're acting like the person you fear becoming.\n\n`;
    }

    // Closing (brutal)
    script += `Tomorrow. ${identity.daily_non_negotiable || 'your promise'}. `;
    script += `Don't make me call you with this same bullshit again.`;

    const wordCount = script.split(' ').length;
    const estimatedDuration = Math.ceil((wordCount / 150) * 60);

    return {
      script,
      weapons_deployed: weapons,
      estimated_duration: estimatedDuration
    };
  }

  /**
   * Generate emergency call script (for when user is about to quit)
   */
  generateEmergencyCallScript(identity: any): CallGeneration {
    const weapons: string[] = [];
    let script = '';

    // Opening (urgent)
    script += `${identity.identity_name || 'HEY'}! BigBruh. Don't you dare quit.\n\n`;

    // Weapon 1: Breaking Point
    if (identity.breaking_point_event) {
      weapons.push('breaking_point');
      script += `You said "${identity.breaking_point_event}" would make you change. `;
      script += `This is that moment. Right now.\n\n`;
    }

    // Weapon 2: War Cry (repeated)
    if (identity.war_cry_voice) {
      weapons.push('war_cry');
      script += `Your war cry: "${identity.war_cry_voice}". `;
      script += `SCREAM IT. RIGHT NOW.\n\n`;
    }

    // Weapon 3: Non-negotiable
    if (identity.non_negotiable_commitment) {
      weapons.push('non_negotiable');
      script += `You promised: "${identity.non_negotiable_commitment}". `;
      script += `This is non-negotiable.\n\n`;
    }

    // Closing (intense)
    script += `One more day. Just one more day. `;
    script += `Then decide. But finish today.`;

    const wordCount = script.split(' ').length;
    const estimatedDuration = Math.ceil((wordCount / 150) * 60);

    return {
      script,
      weapons_deployed: weapons,
      estimated_duration: estimatedDuration
    };
  }

  /**
   * Get available voices
   */
  async getVoices(): Promise<any[]> {
    const response = await fetch('https://api.elevenlabs.io/v1/voices', {
      headers: {
        'xi-api-key': this.apiKey,
      },
    });

    if (!response.ok) {
      throw new Error(`ElevenLabs API error: ${response.statusText}`);
    }

    const data = await response.json();
    return data.voices;
  }
}
