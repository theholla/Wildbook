package org.ecocean.rest;

import org.ecocean.Encounter;
import org.ecocean.MarkedIndividual;
import org.ecocean.Shepherd;
import org.ecocean.SinglePhotoVideo;
import org.ecocean.User;
import org.ecocean.security.Stormpath;

import com.stormpath.sdk.account.Account;
import com.stormpath.sdk.account.AccountList;
import com.stormpath.sdk.client.Client;
import com.stormpath.sdk.directory.CustomData;

public class SimpleFactory {
    private SimpleFactory() {
        // prevent instantiation
    }


    public static SimpleIndividual getIndividual(final String context,
                                                 final Client client,
                                                 final String id) {
        Shepherd myShepherd = new Shepherd(context);
        MarkedIndividual mi = myShepherd.getMarkedIndividual(id);

        if (mi == null) {
            return null;
        }

        return getIndividual(context, client, mi);
    }


    public static SimpleUser getUser(final String context,
                                     final String username) {
        Shepherd myShepherd = new Shepherd(context);
        User user = myShepherd.getUser(username);

        if (user == null) {
            return null;
        }

        return getUser(user);
    }


    public static SimpleIndividual getIndividual(final String context,
                                                 final Client client,
                                                 final MarkedIndividual mi) {

        SimpleIndividual ind = new SimpleIndividual(mi.getIndividualID(), mi.getNickName());
        ind.setSex(mi.getSex());
        //
        // TODO: expose and fix thumbnail path if needed? Or just get from first image?
        //
//        ind.setThumbnail(mi.getThumbnail());

        java.util.Iterator<Encounter> it = mi.getEncounters().iterator();
        while (it.hasNext()) {
            Encounter enc = it.next();
            ind.addEncounter(getEncounter(context, client, enc));
        }

        //
        // TODO: Have photos for individual be chosen from the "selected" or "highlighted"
        // photos via a tag or whatever method we want the users to specify which are the best
        // images. For now I'm just going to grab 8 or so images from all the encounters, grabbing
        // the top images from each.
        //
        int count = 0;
        int index = 0;
        final int MAX_PHOTOS = 8;
        int lastCount = Integer.MAX_VALUE;
        while (count < MAX_PHOTOS && count != lastCount) {
            lastCount = count;
            for (SimpleEncounter encounter : ind.getEncounters()) {
                if (encounter.getPhotos().size() > index) {
                    ind.addPhoto(encounter.getPhotos().get(index));
                    count++;
                }
            }
            index++;
        }

        return ind;
    }


    public static SimpleEncounter getEncounter(final String context, final Client client, final Encounter encounter)
    {
        SimpleEncounter se = new SimpleEncounter(encounter.getDWCGlobalUniqueIdentifier(),
                                                 encounter.getDateInMilliseconds());

        se.setLocationid(encounter.getLocationID());
        se.setVerbatimLocation(encounter.getLocation());
        se.setLatitude(encounter.getLatitude());
        se.setLongitude(encounter.getLongitude());

        encounter.getSubmitterName();
        for (SinglePhotoVideo photo : encounter.getSinglePhotoVideo())
        {
            se.addPhoto(getPhoto(context, photo));
        }

        AccountList accounts = Stormpath.getAccounts(client, encounter.getSubmitterID());

        if (accounts.getSize() < 1) {
            Shepherd myShepherd = new Shepherd(context);
            User user = myShepherd.getUser(encounter.getSubmitterID());

            if (user != null) {
                se.setSubmitter(getUser(user));
            }
        } else {
            Account account = accounts.iterator().next();
            se.setSubmitter(getStormpathUser(account));
        }

        return se;
    }


    public static SimplePhoto getPhoto(final String context,
                                       final SinglePhotoVideo spv)
    {
        SimplePhoto sp = new SimplePhoto(spv.getDataCollectionEventID(),
                                         spv.asUrl(context));
        return sp;
    }


    public static SimpleUser getUser(final User user)
    {
        System.out.println(user.getUsername());
        System.out.println(user.getEmailAddress());
        SimpleUser su = new SimpleUser(user.getUsername(), user.getEmailAddress());

        if (user.getUserImage() != null) {
            su.setAvatar(user.getUserImage().webPath().getFile());
        }

        su.setAffiliation(user.getAffiliation());
        su.setFullName(user.getFullName());

        return su;
    }


    public static SimpleUser getStormpathUser(final Account user)
    {
        SimpleUser su = new SimpleUser(user.getUsername(), user.getEmail());

        CustomData data = user.getCustomData();

        su.setAffiliation((String)data.get("affiliation"));
        su.setFullName(user.getFullName());

        return su;
    }
}