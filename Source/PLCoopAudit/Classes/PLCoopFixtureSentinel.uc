class PLCoopFixtureSentinel extends CoopPLTravelSentinel;
function bool IsParticipant(Controller C)
{
    return C.Tag=='TeamFixture';
}
