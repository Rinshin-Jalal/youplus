/**
 * Type-Safe Database Query Builders
 * 
 * This module provides type-safe query builders for Supabase operations.
 * It ensures that database queries are type-checked at compile time and
 * provides a more ergonomic API for common database operations.
 * 
 * Benefits:
 * 1. Compile-time type checking for database queries
 * 2. Autocomplete for table names and column names
 * 3. Type-safe query parameters
 * 4. Clear error messages for type mismatches
 * 5. Reduced runtime errors due to type issues
 */

import { Database } from "@/types/database";
import { SupabaseClient } from "@supabase/supabase-js";

// Type helpers for database operations
type TableName = keyof Database["public"]["Tables"];
type Row<T extends TableName> = Database["public"]["Tables"][T]["Row"];
type Insert<T extends TableName> = Database["public"]["Tables"][T]["Insert"];
type Update<T extends TableName> = Database["public"]["Tables"][T]["Update"];

/**
 * Type-safe query builder for a specific table
 */
export class TypedQueryBuilder<T extends TableName> {
  constructor(
    protected client: SupabaseClient<Database>,
    private table: T
  ) {}

  /**
   * Select rows with type safety
   */
  select<K extends keyof Row<T>>(...columns: K[]) {
    return this.client
      .from(this.table)
      .select(columns.join(","))
      .returns<Pick<Row<T>, K>[]>();
  }

  /**
   * Select all columns
   */
  selectAll() {
    return this.client.from(this.table).select("*").returns<Row<T>[]>();
  }

  /**
   * Select a single row by ID
   */
  selectById(id: string) {
    return this.client
      .from(this.table)
      .select("*")
      .eq("id", id)
      .maybeSingle()
      .returns<Row<T> | null>();
  }

  /**
   * Insert a new row with type safety
   */
  insert(data: Insert<T>) {
    return this.client.from(this.table).insert(data).select().returns<Row<T>>();
  }

  /**
   * Insert multiple rows with type safety
   */
  insertMany(data: Insert<T>[]) {
    return this.client.from(this.table).insert(data).select().returns<Row<T>[]>();
  }

  /**
   * Update a row by ID with type safety
   */
  updateById(id: string, data: Update<T>) {
    return this.client
      .from(this.table)
      .update(data)
      .eq("id", id)
      .select()
      .returns<Row<T>>();
  }

  /**
   * Update rows matching a filter with type safety
   */
  update(filter: Partial<Row<T>>, data: Update<T>) {
    let query = this.client.from(this.table).update(data);
    
    // Apply all filter conditions
    Object.entries(filter).forEach(([key, value]) => {
      query = query.eq(key, value);
    });
    
    return query.select().returns<Row<T>[]>();
  }

  /**
   * Delete a row by ID
   */
  deleteById(id: string) {
    return this.client.from(this.table).delete().eq("id", id);
  }

  /**
   * Filter by a specific column
   */
  where<K extends keyof Row<T>>(column: K, value: Row<T>[K]) {
    return this.client
      .from(this.table)
      .select("*")
      .eq(column as string, value)
      .returns<Row<T>[]>();
  }

  /**
   * Filter by multiple conditions
   */
  whereMultiple(conditions: Partial<Row<T>>) {
    let query = this.client.from(this.table).select("*");
    
    Object.entries(conditions).forEach(([key, value]) => {
      query = query.eq(key, value);
    });
    
    return query.returns<Row<T>[]>();
  }

  /**
   * Order results by a column
   */
  orderBy<K extends keyof Row<T>>(column: K, ascending: boolean = true) {
    return this.client
      .from(this.table)
      .select("*")
      .order(column as string, { ascending })
      .returns<Row<T>[]>();
  }

  /**
   * Limit results
   */
  limit(count: number) {
    return this.client
      .from(this.table)
      .select("*")
      .limit(count)
      .returns<Row<T>[]>();
  }

  /**
   * Get raw query builder for complex operations
   */
  get raw() {
    return this.client.from(this.table);
  }
}

/**
 * Create a typed query builder for a specific table
 */
export function createTypedQueryBuilder<T extends TableName>(
  client: SupabaseClient<Database>,
  table: T
): TypedQueryBuilder<T> {
  return new TypedQueryBuilder(client, table);
}

/**
 * Specialized query builders for common tables
 */

// Users table query builder
export class UsersQueryBuilder extends TypedQueryBuilder<"users"> {
  constructor(client: SupabaseClient<Database>) {
    super(client, "users");
  }

  /**
   * Find users by subscription status
   */
  findBySubscriptionStatus(status: "active" | "trialing" | "cancelled" | "past_due") {
    return this.where("subscription_status", status);
  }

  /**
   * Find users who completed onboarding
   */
  findCompletedOnboarding() {
    return this.where("onboarding_completed", true);
  }

  /**
   * Update user's push token
   */
  updatePushToken(userId: string, token: string | null) {
    const updateData: Database["public"]["Tables"]["users"]["Update"] = {};
    if (token !== null) {
      updateData.push_token = token;
    }
    return this.updateById(userId, updateData);
  }
}

// Promises table query builder
export class PromisesQueryBuilder extends TypedQueryBuilder<"promises"> {
  constructor(client: SupabaseClient<Database>) {
    super(client, "promises");
  }

  /**
   * Find promises for a specific user and date
   */
  findByUserAndDate(userId: string, date: string) {
    return this.whereMultiple({ user_id: userId, promise_date: date });
  }

  /**
   * Find promises by status
   */
  findByStatus(status: "pending" | "kept" | "broken") {
    return this.where("status", status);
  }

  /**
   * Find today's promises for a user
   */
  findTodaysPromises(userId: string) {
    const today = new Date().toISOString().split('T')[0];
    if (!today) throw new Error("Could not generate today's date");
    return this.findByUserAndDate(userId, today);
  }

  /**
   * Update promise status
   */
  updateStatus(promiseId: string, status: "pending" | "kept" | "broken", excuseText?: string) {
    const updateData: Database["public"]["Tables"]["promises"]["Update"] = { status };
    if (excuseText) {
      updateData.excuse_text = excuseText;
    }
    return this.updateById(promiseId, updateData);
  }
}

// Calls table query builder
export class CallsQueryBuilder extends TypedQueryBuilder<"calls"> {
  constructor(client: SupabaseClient<Database>) {
    super(client, "calls");
  }

  /**
   * Find calls for a user by type
   */
  findByUserAndType(userId: string, callType: Database["public"]["Tables"]["calls"]["Row"]["call_type"]) {
    return this.whereMultiple({ user_id: userId, call_type: callType });
  }

  /**
   * Find calls within a date range
   */
  findByDateRange(userId: string, startDate: string, endDate: string) {
    return this.client
      .from("calls")
      .select("*")
      .eq("user_id", userId)
      .gte("created_at", startDate)
      .lte("created_at", endDate)
      .returns<Row<"calls">[]>();
  }

  /**
   * Find successful calls
   */
  findSuccessfulCalls() {
    return this.where("call_successful", "success");
  }
}

// Identity table query builder
export class IdentityQueryBuilder extends TypedQueryBuilder<"identity"> {
  constructor(client: SupabaseClient<Database>) {
    super(client, "identity");
  }

  /**
   * Find identity by user ID
   */
  findByUserId(userId: string) {
    return this.where("user_id", userId);
  }

  /**
   * Update identity fields
   */
  updateIdentityFields(userId: string, fields: Partial<Database["public"]["Tables"]["identity"]["Update"]>) {
    return this.client
      .from("identity")
      .update(fields)
      .eq("user_id", userId)
      .select()
      .returns<Row<"identity">>();
  }
}

/**
 * Factory function to create specialized query builders
 */
export function createQueryBuilders(client: SupabaseClient<Database>) {
  return {
    users: new UsersQueryBuilder(client),
    promises: new PromisesQueryBuilder(client),
    calls: new CallsQueryBuilder(client),
    identity: new IdentityQueryBuilder(client),
    // Generic query builder for any table
    table: <T extends TableName>(table: T) => createTypedQueryBuilder(client, table),
  };
}

/**
 * Type-safe transaction helper
 */
export async function transaction<T>(
  client: SupabaseClient<Database>,
  callback: (queryBuilders: ReturnType<typeof createQueryBuilders>) => Promise<T>
): Promise<T> {
  // Note: Supabase doesn't have built-in transaction support like traditional databases
  // This is a placeholder for future transaction implementation
  // For now, we'll just execute the callback with the query builders
  const queryBuilders = createQueryBuilders(client);
  return callback(queryBuilders);
}