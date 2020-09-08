module Morphir.Reference.Model.BooksAndRecords exposing (..)

import Morphir.SDK.StatefulApp exposing (StatefulApp(..))



{- Type aliases for modeling in the language of the business -}


type alias ID =
    String


type alias ProductID =
    String


type alias Price =
    Float


type alias Quantity =
    Int



{- Identifies a structure that can be associated to a persistance entity -}


type alias Deal =
    { product : ProductID
    , price : Price
    , quantity : Quantity
    }



{- These define the requests that can be made of this service -}


type DealCmd
    = OpenDeal ProductID Price Quantity
    | CloseDeal



{- These define the responses that would result from requests -}


type DealEvent
    = DealOpened ProductID Price Quantity
    | DealClosed
    | InvalidQuantity Quantity
    | InvalidPrice Price
    | DuplicateDeal
    | DealNotFound



{- Defines that this is a stateful application that uses ID as the entity key (for possible partioning),
   accepts requests of type DealCmd,
   manages data in the form of a Deal,
   and produces events of type DealEvent.

   Note that there's no indication of whether the API is synchronous or asynchronous.  That's up to the implementation to decide.
-}
{- Defines the business logic of this app.
   That is whether or not to accept a request to open or close a deal.
-}


logic : Maybe Deal -> DealCmd -> ( Maybe Deal, DealEvent )
logic dealState dealCmd =
    -- Act accordingly based on whether the deal already exists.
    case dealState of
        Just _ ->
            case dealCmd of
                CloseDeal ->
                    ( Nothing, DealClosed )

                OpenDeal _ _ _ ->
                    ( dealState, DuplicateDeal )

        Nothing ->
            case dealCmd of
                OpenDeal productId price qty ->
                    if price < 0 then
                        ( dealState, InvalidPrice price )

                    else if qty < 0 then
                        ( dealState, InvalidQuantity qty )

                    else
                        ( Deal productId price qty |> Just
                        , DealOpened productId price qty
                        )

                CloseDeal ->
                    ( dealState, DealNotFound )


app : StatefulApp ID DealCmd Deal DealEvent
app =
    StatefulApp logic
