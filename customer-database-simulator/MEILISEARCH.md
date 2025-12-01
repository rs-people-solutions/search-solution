# Configuring a Meilisearch 'customers' Index

This guide outlines the steps to configure a Meilisearch index named `customers`. We will perform three main operations:
1.  Set the initial searchable attributes and ranking rules for relevance.
2.  Enable sorting by the `id` attribute.
3.  Update the ranking rules to prioritize sorting when a sort parameter is used.

These operations are performed sequentially using `PATCH` requests, which allow for partial updates to the index settings.

## 1. Set Initial Searchable Attributes and Ranking Rules

First, we define which document attributes Meilisearch should search within and establish the initial criteria for ranking the search results.

-   **`searchableAttributes`**: Specifies the list of attributes that the search engine will scan for matching query words. Here, we allow searching on `firstName`, `lastName`, a combined `_searchableName` field, and `email`.
-   **`rankingRules`**: Defines the sequence of rules Meilisearch uses to sort results by relevance. The default order is a great starting point for most use cases.

### Command

```shell
curl -X PATCH "http://127.0.0.1:7700/indexes/customers/settings" \
-H "Content-Type: application/json" \
-d '{
  "searchableAttributes": ["firstName","lastName","_searchableName","email"],
  "rankingRules": ["words","typo","proximity","attribute","exactness"]
}'
```

---

## 2. Make `id` Sortable

To allow search results to be sorted by a specific attribute at query time, you must first add that attribute to the `sortableAttributes` list. In this step, we make the `id` attribute available for sorting. This is useful for ordering customers by their creation order or a unique identifier.

### Command

```shell
curl -X PATCH "http://127.0.0.1:7700/indexes/customers/settings" \
-H "Content-Type: application/json" \
-d '{
  "sortableAttributes": ["id"]
}'
```

---

## 3. Prioritize Sorting in Ranking Rules

By default, Meilisearch prioritizes search relevance over sorting. To make sorting the **primary** criterion when a `sort` parameter is provided in a search query, you must add the `sort` rule to the beginning of the `rankingRules` array.

When `sort` is the first rule:
-   If a query includes `sort=id:asc`, the results will first be sorted by `id` in ascending order.
-   Relevance rules (`words`, `typo`, etc.) will then be used as tie-breakers for documents that have the same `id` value.

### Command

```shell
curl -X PATCH "http://127.0.0.1:7700/indexes/customers/settings" \
-H "Content-Type: application/json" \
-d '{
  "rankingRules": ["sort","words","typo","proximity","attribute","exactness"]
}'
```

## Summary of Final Settings

After executing these three commands, the `customers` index will have the following settings configured:

```json
{
  "searchableAttributes": [
    "firstName",
    "lastName",
    "_searchableName",
    "email"
  ],
  "sortableAttributes": [
    "id"
  ],
  "rankingRules": [
    "sort",
    "words",
    "typo",
    "proximity",
    "attribute",
    "exactness"
  ]
}
```