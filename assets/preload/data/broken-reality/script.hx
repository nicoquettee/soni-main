function onEvent(n, v1, v2)
{
    if(n == 'Bil Reset')
    {
        PlayState.strumLineNotes.members[0].x = defaultOpponentStrumX0;
        PlayState.strumLineNotes.members[1].x = defaultOpponentStrumX1;
        PlayState.strumLineNotes.members[2].x = defaultOpponentStrumX2;
        PlayState.strumLineNotes.members[3].x = defaultOpponentStrumX3;

        PlayState.strumLineNotes.members[4].x = defaultPlayerStrumX0;
        PlayState.strumLineNotes.members[5].x = defaultPlayerStrumX1;
        PlayState.strumLineNotes.members[6].x = defaultPlayerStrumX2;
        PlayState.strumLineNotes.members[7].x = defaultPlayerStrumX3;
    }
}