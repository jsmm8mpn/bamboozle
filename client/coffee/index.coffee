hangoutId = getParameterByName("roomId")
@hangoutId = (if (hangoutId) then hangoutId else "h1")
userId = getParameterByName("userId")
@userId = (if (userId) then userId else "u1")