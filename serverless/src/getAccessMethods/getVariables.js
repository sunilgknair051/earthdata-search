import { computeKeywordMappings } from './computeKeywordMappings'

/**
 * Given the items result from a CMR variable search, returns the variables in an object with the key being the concept id
 * and the value being the variable metadata
 * @param {Array} items Items key from a CMR variable search result
 */
const computeVariables = (items) => {
  const variables = {}

  items.forEach((variable) => {
    const { conceptId: variableId } = variable

    variables[variableId] = variable
  })

  return variables
}

/**
 * Fetches the variable metadata for the provided variableIds
 * @param {Array} variableIds An array of variable Concept Ids
 * @param {String} jwtToken JWT returned from edlAuthorizer
 */
export const getVariables = (data) => {
  const { items = [] } = data || {}

  const keywordMappings = computeKeywordMappings(items)
  const variables = computeVariables(items)

  return { keywordMappings, variables }
}
