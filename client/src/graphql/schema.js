import gql from 'graphql-tag'

export default gql`
    # extend type Player {
    #     present: Boolean!
    # }
    # extend type Profile {}
  type Player {
    id: ID!
    status: String!
    insertedAt: DateTime!
    updatedAt: DateTime!
    profile: Profile!
  }

  type Profile {
    id: ID!
    nickname: String!
    email: String!
    insertedAt: DateTime!
    updatedAt: DateTime!
  }
`
