describe 'Leaderboard', ->
  before ->
    @redisConnection = redis.createClient(6379, 'localhost')

  beforeEach ->
    @leaderboard = new Leaderboard('highscores')
  
  afterEach ->
    @redisConnection.flushdb()

  it 'should initialize the leaderboard correctly', (done) ->
    @leaderboard.leaderboardName.should.equal('highscores')
    @leaderboard.reverse.should.be.false
    @leaderboard.pageSize.should.equal(Leaderboard.DEFAULT_pageSize)

    done()

  it 'should initialize the leaderboard correctly with options', (done) ->
    updated_options = 
      'pageSize': -1
      'reverse': true

    @leaderboard = new Leaderboard('highscores', updated_options)
    @leaderboard.leaderboardName.should.equal('highscores')
    @leaderboard.reverse.should.be.true
    @leaderboard.pageSize.should.equal(Leaderboard.DEFAULT_pageSize)

    done()

  it 'should allow you to disconnect the Redis connection', (done) ->
    @leaderboard.disconnect()
    done()

  it 'should allow you to delete a leaderboard', (done) ->
    @leaderboard.rankMember('member', 1, 'Optional member data', (reply) -> )
    @leaderboard.redisConnection.exists('highscores', (err, reply) ->
      reply.should.equal(1))
    @leaderboard.redisConnection.exists('highscores:member_data', (err, reply) ->
      reply.should.equal(1))
    @leaderboard.deleteLeaderboard((reply) -> )
    @leaderboard.redisConnection.exists('highscores', (err, reply) ->
      reply.should.equal(0))
    @leaderboard.redisConnection.exists('highscores:member_data', (err, reply) ->
      reply.should.equal(0))

    done()

  it 'should return the total number of members in the leaderboard', (done) ->
    @leaderboard.totalMembers((reply) ->
      reply.should.equal(0)
      done())

  it 'should allow you to rank a member in the leaderboard and see that reflected in total members', (done) ->
    @leaderboard.rankMember('member', 1, null, (reply) -> )

    @leaderboard.totalMembers((reply) ->
      reply.should.equal(1)
      done())

  it 'should allow you to rank a member in the leaderboard with optional member data and see that reflected in total members', (done) ->
    @leaderboard.rankMember('member', 1, 'Optional member data', (reply) -> )

    @leaderboard.totalMembers((reply) ->
      reply.should.equal(1))
    
    @leaderboard.memberDataFor('member', (reply) ->
      reply.should.equal('Optional member data')
      done())

  it 'should allow you to retrieve optional member data', (done) ->
    @leaderboard.rankMember('member', 1, 'Optional member data', (reply) -> )

    @leaderboard.memberDataFor('member', (reply) ->
      reply.should.equal('Optional member data')
      done())

  it 'should allow you to update optional member data', (done) ->
    @leaderboard.rankMember('member', 1, 'Optional member data', (reply) -> )

    @leaderboard.memberDataFor('member', (reply) ->
      reply.should.equal('Optional member data'))

    @leaderboard.updateMemberData('member', 'Updated member data', (reply) -> )

    @leaderboard.memberDataFor('member', (reply) ->
      reply.should.equal('Updated member data')
      done())

  it 'should allow you to remove optional member data', (done) ->
    @leaderboard.rankMember('member', 1, 'Optional member data', (reply) -> )

    @leaderboard.memberDataFor('member', (reply) ->
      reply.should.equal('Optional member data'))

    @leaderboard.removeMemberData('member', (reply) -> )

    @leaderboard.memberDataFor('member', (reply) ->
      should_helper.not.exist(reply)
      done())

  it 'should allow you to remove a member', (done) ->
    @leaderboard.rankMember('member', 1, 'Optional member data', (reply) -> )

    @leaderboard.memberDataFor('member', (reply) ->
      reply.should.equal('Optional member data'))

    @leaderboard.removeMember('member', (reply) -> )

    @leaderboard.totalMembers((reply) ->
      reply.should.equal(0))

    @leaderboard.memberDataFor('member', (reply) ->
      should_helper.not.exist(reply)
      done())

  it 'should return the correct total pages', (done) ->
    for index in [0...Leaderboard.DEFAULT_pageSize + 1]
      @leaderboard.rankMember("member#{index}", index, null, (reply) -> )

    @leaderboard.totalPages(5, (reply) ->
      reply.should.equal(6))

    @leaderboard.totalPages(null, (reply) ->
      reply.should.equal(2))

    @leaderboard.totalPages(Leaderboard.DEFAULT_pageSize, (reply) ->
      reply.should.equal(2)
      done())
